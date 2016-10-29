public with sharing class TwitterAuthorization {

	public static final String TWITTER_API_OAUTH_URL = 'https://api.twitter.com/oauth';
	public static final String REQUEST_AUTH_TOKEN_URL = TWITTER_API_OAUTH_URL + '/request_token';
	public static final String REQUEST_ACCESS_TOKEN_URL = TWITTER_API_OAUTH_URL + '/access_token';
	public static final String AUTHENTICATE_URL = TWITTER_API_OAUTH_URL + '/authenticate';

	public static final String GET = 'GET';
	public static final String POST = 'POST';

	/**
	 * @description Request Authorization Token and Authorization Token Secret keys
	 * @return void
	*/
	public void requestAuthToken() {

		HttpRequest request = TwitterManager.prepareRequest(REQUEST_AUTH_TOKEN_URL, POST);

		HttpResponse response = new HttpRequestHandler(request).call();

		if (response.getStatusCode() != 200) {

			throw new TwitterException(response.getBody());

		} else if (String.isNotEmpty(response.getBody())) {

			Map<String,Object> tokens = TwitterService.splitParameters(response.getBody());

			Boolean isCallbackConfirmed = (
				tokens.containsKey('oauth_callback_confirmed') &&
				Boolean.valueOf(tokens.get('oauth_callback_confirmed'))
			);

			if (isCallbackConfirmed) {
				TwitterSettings__c settings = TwitterSettings__c.getOrgDefaults();

				settings.AuthorizationToken__c = String.valueOf(tokens.get('oauth_token'));
				settings.AccessTokenSecret__c = String.valueOf(tokens.get('oauth_token_secret'));

				Database.update(settings);
			}
		} else {
			throw new TwitterException('During requesting authorization token response body is empty.');
		}
	}

	/**
	 * @description Redirect a user to Twitter authentication page.
	 * @return PageReference is redirect url.
	*/
	public PageReference authenticateUser() {

		TwitterSettings__c settings = TwitterSettings__c.getOrgDefaults();

		PageReference pr = new PageReference(AUTHENTICATE_URL);
		pr.getParameters().put('oauth_token', settings.AuthorizationToken__c);
		pr.setRedirect(true);

		return pr;
	}

	/**
	 * @description Request Access Token / Access Token Secret via
	 * 		Authorization Token and Authorization Verifier values getting on previous step.
	 * @param p_authorizationToken is temporary Authorization Token value getting after authentication a user.
	 * @param p_authorizationVerifier is verification token value getting after authentication a user.
	 * @return void
	*/
	public void requestAccessToken(String p_authorizationToken, String p_authorizationVerifier) {

		TwitterSettings__c settings = TwitterSettings__c.getOrgDefaults();

		//TODO: Need to check if this is the same auth token that is stored already.
		if (settings.AuthorizationToken__c != p_authorizationToken) {
			throw new TwitterException('Authorization Token is not the same as on previous step.');
		}

		String requestBody = 'oauth_verifier=' + p_authorizationVerifier;

		HttpRequest request = TwitterManager.prepareRequest(REQUEST_ACCESS_TOKEN_URL, POST, requestBody);

		HttpResponse response = new HttpRequestHandler(request).call();

		if (String.isNotEmpty(response.getBody())) {

			Map<String,Object> tokens = TwitterService.splitParameters(response.getBody());

			settings.AccessToken__c = String.valueOf(tokens.get('oauth_token'));
			settings.AccessTokenSecret__c = String.valueOf(tokens.get('oauth_token_secret'));
			settings.AuthorizationToken__c = '';

			Database.update(settings);

		} else {
			throw new TwitterException('During requesting access token response body is empty.');
		}
	}

	public class TwitterException extends Exception {}
}