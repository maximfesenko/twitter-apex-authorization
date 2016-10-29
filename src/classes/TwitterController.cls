public with sharing class TwitterController {
	public TwitterController() {

	}

	public PageReference init() {

		Map<String,String> parameters = ApexPages.currentPage().getParameters();

		if (parameters.isEmpty()) {
			TwitterAuthorization twitter = new TwitterAuthorization();
			twitter.requestAuthToken();

			return twitter.authenticateUser();

		} else if (parameters.containsKey('oauth_token') && parameters.containsKey('oauth_verifier')) {

			String authToken = parameters.get('oauth_token');
			String authVerifier = parameters.get('oauth_verifier');

			new TwitterAuthorization().requestAccessToken(authToken, authVerifier);
		}

		return NULL;

	}
}