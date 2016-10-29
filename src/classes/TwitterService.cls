/**
 * @description Service class to store helpul method for Twitter actions.
*/
public with sharing class TwitterService {

	/**
	 * @descripiton
	*/
	public static String generateSignature(TwitterSettings__c p_settings, String p_endpoint, String p_method, Map<String,String> p_parameters) {

		String baseString = getBaseString(p_endpoint, p_method, p_parameters);

		String encodedConsumerSecret = EncodingUtil.urlEncode(p_settings.ConsumerSecret__c, 'UTF-8');
		String encodedAuthTokenSecret = '';

		if (String.isNotEmpty(p_settings.AccessTokenSecret__c)) {
			encodedAuthTokenSecret = EncodingUtil.urlEncode(p_settings.AccessTokenSecret__c, 'UTF-8');
		}

		String key = encodedConsumerSecret + '&' + encodedAuthTokenSecret;

		Blob sig = Crypto.generateMac(
			'HmacSHA1',
			Blob.valueOf(baseString),
			Blob.valueOf(key)
		);

		String signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');

		return signature;
	}

	/**
	 * @descripiton
	*/
	public static String generateHeader(Map<String,String> p_parameters) {
		List<String> keys = new List<String>();
		for (String key : p_parameters.keySet()) {
			keys.add(key + '="' + p_parameters.get(key) + '"');
		}

		return 'OAuth ' + String.join(keys, ', ');
	}

	/**
	 * @descripiton
	*/
	public static String generateAuthorizationHeader(HttpRequest p_request, TwitterSettings__c p_settings, Map<String,String> p_parameters) {

		//Map<String,String> parameters = prepareHeaderParams(p_settings, p_paramNames);

		String oauth_signature = generateSignature(p_settings, p_request.getEndpoint(), p_request.getMethod(), p_parameters);
		p_parameters.put('oauth_signature', oauth_signature);

		return generateHeader(p_parameters);
	}

	/**
	 * @descripiton
	*/
	public static Map<String,String> prepareHeaderParams(TwitterSettings__c p_settings) {

		String nonce = String.valueof(DateTime.now().getTime() / 1000);
		String timestamp = String.valueof(DateTime.now().getTime() / 1000);

		Map<String,String> parameters = new Map<String,String>();
		parameters.put('oauth_consumer_key', p_settings.ConsumerKey__c);
		parameters.put('oauth_nonce', nonce);
		parameters.put('oauth_signature_method', 'HMAC-SHA1');
		parameters.put('oauth_timestamp', timestamp);
		parameters.put('oauth_version', '1.0');

		return parameters;
	}

	/**
	 * @descripiton
	*/
	public static Map<String,Object> splitParameters(String p_paramString) {

		Map<String,Object> tokens = new Map<String,String>();
		List<String> params = p_paramString.split('&');

		for (String param : params) {

			List<String> token = param.split('=');
			String name = token.get(0);
			String value = token.get(1);

			tokens.put(name, value);
		}

		return tokens;
	}

	/**
	 * @descripiton
	*/
	private static String encodeParameters(Map<String,String> p_parameters) {

		List<String> keys = new List<String>(p_parameters.keySet());
		keys.sort();

		List<String> urlParameters = new List<String>();
		for (String key : keys) {
			urlParameters.add(key + '=' + p_parameters.get(key));
		}

		return EncodingUtil.urlEncode(String.join(urlParameters, '&'), 'UTF-8');
	}

	/**
	 * @descripiton
	*/
	private static String getBaseString(String p_endpoint, String p_method, Map<String,String> p_parameters) {

		Map<String,String> p = p_parameters.clone();
		String host = p_endpoint.substringBefore('?');
		String parametersString = p_endpoint.substringAfter('?');

		if (String.isNotEmpty(parametersString)) {

			Map<String,String> params = (Map<String,String>)splitParameters(parametersString);

			p.putAll(params);
		}

		String method = p_method.toUpperCase();
		String encodedHost = EncodingUtil.urlEncode(host, 'UTF-8');
		String encodedParams = encodeParameters(p);

		return method + '&' + encodedHost + '&' + encodedParams;
	}

}