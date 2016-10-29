public with sharing class TwitterManager {

	public static final String TWITTER_API_URL = 'https://api.twitter.com/1.1';

	public static final String CONTENT_TYPE = 'Content-Type';
	public static final String APPLICATION_JSON = 'application/json';
	public static final String APPLICATION_FORM = 'application/x-www-form-urlencoded';

	public static HttpRequest prepareRequest(String p_endpoint, String p_method) {
		return prepareRequest(p_endpoint, p_method, '');
	}

	public static HttpRequest prepareRequest(String p_endpoint, String p_method, String p_body) {

		TwitterSettings__c settings = TwitterSettings__c.getOrgDefaults();
		HttpRequest request = new HttpRequest();

		request.setEndpoint(p_endpoint);
		request.setMethod(p_method);

		Map<String,String> parameters = TwitterService.prepareHeaderParams(settings);

		if (p_endpoint.startsWithIgnoreCase(TwitterAuthorization.REQUEST_AUTH_TOKEN_URL)) {

			settings.AuthorizationToken__c = '';
			settings.AccessTokenSecret__c = '';

			request.setHeader(CONTENT_TYPE, APPLICATION_JSON);

			parameters.put('oauth_callback', EncodingUtil.urlEncode(settings.CallbackURL__c, 'UTF-8'));

		} else if (p_endpoint.startsWithIgnoreCase(TwitterAuthorization.REQUEST_ACCESS_TOKEN_URL)) {

			request.setHeader(CONTENT_TYPE, APPLICATION_FORM);
			request.setBody(p_body);

			parameters.put('oauth_token', settings.AuthorizationToken__c);

		} else if (p_endpoint.startsWithIgnoreCase(TWITTER_API_URL + '/users/search.json')) {

			request.setHeader(CONTENT_TYPE, APPLICATION_JSON);

			parameters.put('oauth_token', settings.AccessToken__c);
		}

		String authorizationHeader = TwitterService.generateAuthorizationHeader(request, settings, parameters);
		request.setHeader('Authorization', authorizationHeader);

		return request;
	}
}