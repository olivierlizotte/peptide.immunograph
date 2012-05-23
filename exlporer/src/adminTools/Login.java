package adminTools;

import graphDB.explore.DefaultTemplate;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import org.neo4j.graphdb.*;
import org.neo4j.kernel.EmbeddedGraphDatabase;

public class Login {
	
	static void registerShutdownHook( final GraphDatabaseService graphDb )
	{
	    // Registers a shutdown hook for the Neo4j instance so that it
	    // shuts down nicely when the VM exits (even if you "Ctrl-C" the
	    // running example before it's completed)
	    Runtime.getRuntime().addShutdownHook( new Thread()
	    {
	        @Override
	        public void run()
			{
	            graphDb.shutdown();
			}
		} );
	}
	
	public static StringBuffer convertString(String s) throws NoSuchAlgorithmException{
		MessageDigest mdAlgorithm = MessageDigest.getInstance("MD5");
		mdAlgorithm.update(s.getBytes());
		
		byte[] digest = mdAlgorithm.digest();
		StringBuffer encodedStr = new StringBuffer();
		
		for (int i = 0; i < digest.length; i++) {
		    s = Integer.toHexString(0xFF & digest[i]);
		    if (s.length() < 2) {
		        s = "0" + s;
		    }
		    encodedStr.append(s);
		}
		
		return encodedStr;
	}
	
	public static boolean checkPassword(String login, String passwd) throws NoSuchAlgorithmException {
		String passwdToTest = convertString(passwd).toString();
		
		String correctPasswd="f71dbe52628a3f83a77ab494817525c6";
		if (passwdToTest.trim().equals(correctPasswd.trim())){
			return true;
		}else{
			return false;
		}
	}
	
	public static void addUser(String name, String passwd){
		EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
		try	{
			registerShutdownHook( graphDb );
			Transaction tx = graphDb.beginTx();
				Node userNode = graphDb.createNode();
				userNode.setProperty("type", "User");
				userNode.setProperty("NickName", name);
				userNode.setProperty("passwd", convertString(passwd));
				System.out.println("User ID : " + userNode.getId());
			tx.success();
			tx.finish();
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			graphDb.shutdown();
		}
	}
	
	public static void main(){
		Login.addUser("az", "az");
	}
}
