package graphDB.users;

import graphDB.explore.DefaultTemplate;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import org.neo4j.graphdb.*;
import org.neo4j.graphdb.index.Index;
import org.neo4j.graphdb.index.IndexHits;
import org.neo4j.kernel.EmbeddedGraphDatabase;

public class Login {	
	
	public static void registerShutdownHook( final GraphDatabaseService graphDb )
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
	
	public static long checkPassword(String login, String passwd) throws NoSuchAlgorithmException {
		String passwdToTest = convertString(passwd).toString();
		String correctPasswd="";
		//correctPasswd="f71dbe52628a3f83a77ab494817525c6";
		
		EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
		long userID = -1;
		try	{
			registerShutdownHook( graphDb );
			Index<Node> index = graphDb.index().forNodes("users");
			Node userNode = index.get("NickName", login).getSingle();
			if(userNode != null)
			{
				userID = userNode.getId();
				correctPasswd = userNode.getProperty("passwd").toString();
			}
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			graphDb.shutdown();
		}
		if (passwdToTest.trim().equals(correctPasswd.trim())){
			return userID;
		}else{
			return -1;
		}
	}
	
	public static void addUser(String name, String nickName, String passwd){
		EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
		try	{				
			registerShutdownHook( graphDb );
			Transaction tx = graphDb.beginTx();
			
			Index<Node> index = graphDb.index().forNodes("users");
			Node userNodeExisting = index.get("NickName", nickName).getSingle();
			if(userNodeExisting != null)
				System.out.println("User already exists!");
			else
			{
				Node userNode = graphDb.createNode();
				userNode.setProperty("type", "User");
				userNode.setProperty("name", name);
				userNode.setProperty("NickName", nickName);
				userNode.setProperty("passwd", convertString(passwd).toString());
		
				index.add(userNode, "NickName", nickName);
			
				System.out.println("User ID : " + userNode.getId());
			}
			tx.success();
			tx.finish();
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			graphDb.shutdown();
		}
	}
	
	public static void deleteUser(String name){
		EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
		try	{				
			registerShutdownHook( graphDb );
			Transaction tx = graphDb.beginTx();
			
			Index<Node> index = graphDb.index().forNodes("users");
			IndexHits<Node> nodes = index.get("NickName", name);
			int nbElem = 0;
			for (Node node : nodes) {
				node.delete();
				nbElem++;
			}			
			tx.success();
			tx.finish();
			System.out.println("Deleted " + nbElem + " users.");
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			graphDb.shutdown();
		}
	}
}
