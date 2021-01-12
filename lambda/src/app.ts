import {
    CloudFrontRequestHandler,
    CloudFrontRequestEvent,
    CloudFrontRequestResult,
    CloudFrontHeaders,
    CloudFrontRequest,
} from 'aws-lambda';

import {IParameterStore} from "./aws/parameter-store";
import SsmParameterStore from "./aws/ssm-parameter-store";
import OriginResolver, {UnroutableRequest} from "./origin-resolver";
import FeatureFlagOriginProvider from "./feature-flags/feature-flag-origin-provider";
import LdFeatureFlagResolver from "./feature-flags/ld-feature-flag-resolver";
import {CloudFrontOrigin} from "aws-lambda/common/cloudfront";
import log from 'lambda-log';

let originResolver:OriginResolver;

export const handler: CloudFrontRequestHandler = async (event: CloudFrontRequestEvent): Promise<CloudFrontRequestResult> => {

    const request = event.Records[0].cf.request;
    const headers = request.headers;
    const origin:CloudFrontOrigin | undefined = request.origin;
    const distributionId = event.Records[0].cf.config.distributionId

    log.info(`URI : ${request.uri}`);
    log.info(`headers : ${JSON.stringify(headers)}`);
    log.info(`query string : ${request.querystring}`);
    log.info(`distribution id : ${distributionId}`);

    if(!origin) {
        log.warn('No origin was found, returning prematurely');
        return
    }

    if(!originResolver) {
        return initRouterProvider(distributionId).then(originRouterProvider => {
            originResolver = new OriginResolver(originRouterProvider);
            return processRequest(headers, request, origin)
        })
    } else {
       return processRequest(headers, request, origin)
    }
}

async function initRouterProvider(cfDistroId: string) : Promise<FeatureFlagOriginProvider>{

    log.info('Init called...')

    const ssm : IParameterStore = new SsmParameterStore();

    const legacyDomain =  ssm.getParameterValue(`/routing/${cfDistroId}/legacy-root-domain`)
    const newDomain =  ssm.getParameterValue(`/routing/${cfDistroId}/new-domain`)
    const ldSdkKey =  ssm.getParameterValue(`/routing/${cfDistroId}/legacy-root-domain`)
    const featureFlag =  ssm.getParameterValue(`/launch-darkly/${cfDistroId}/feature-flag`)

    const results = await Promise.all([ldSdkKey, legacyDomain, newDomain, featureFlag]);
    const sdkKey = results[0];
    const defaultDomain = results[1];

    // We route to this domain when the feature flag is true
    const domain = results[2];
    log.info('default domain : ' + defaultDomain);
    log.info('domain : ' + domain);
    const targetFeatureFlag = results[3];

    log.info('targetFeatureFlag : ' + targetFeatureFlag);

    return new FeatureFlagOriginProvider(new LdFeatureFlagResolver(sdkKey), defaultDomain, domain, targetFeatureFlag);
}

async function processRequest(headers: CloudFrontHeaders, request: CloudFrontRequest, origin: CloudFrontOrigin): Promise<CloudFrontRequestResult> {

    try {
        const targetDomain = await originResolver.determineOriginDomain(headers, request.querystring);

        if (origin.custom) {
            origin.custom.domainName = targetDomain;
        } else if (origin.s3) {
            origin.s3.domainName = targetDomain;
        }

        request.origin = origin;
        request.headers['host'] = [{key: 'Host', value: targetDomain}]
    } catch(e) {
        console.log(e.type)
        if(e instanceof UnroutableRequest) {
            console.warn(`Request was not routable, the reason was ${e.message}`)
        } else {
            throw e
        }
    }

    return request;
}
