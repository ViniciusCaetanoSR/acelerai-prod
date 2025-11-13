public without sharing class TeamsOAuth_Response {
	public String access_token;	
	public String expires_in;	//3599
	public String refresh_token;	//1//0hczqV2_sHdn9CgYIARAAGBESNwF-L9Iriu2615S9fnyG6n03NillOS7ksbRiLMqp-f8RN5zZowYZtX1Hyc0Xht3w8bT1pOQkX2A
	public String scope;	
	public String token_type;	//Bearer

	public static TeamsOAuth_Response parse(String json){
		return (TeamsOAuth_Response) System.JSON.deserialize(json, TeamsOAuth_Response.class);
	}
}