<%@page import="scala.util.parsing.json.JSONFormat"%>
<%@ page import="graphDB.explore.*" %>
<%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import ="org.neo4j.graphdb.Direction" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.RelationshipType" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@page import="org.neo4j.cypher.javacompat.*"%>
<%@page import="java.util.*" %>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>

<%

final String TMP_DIR_PATH ="/home/antoine/workspace/tmpDir/";


boolean isMultipart = ServletFileUpload.isMultipartContent(request);
//Create a factory for disk-based file items
FileItemFactory factory = new DiskFileItemFactory();

//Create a new file upload handler
ServletFileUpload upload = new ServletFileUpload(factory);
List items = upload.parseRequest(request);

Iterator<FileItem> iter = items.iterator();
while (iter.hasNext()) {
    FileItem item = (FileItem) iter.next();

    if (!item.isFormField()) {
    	String fieldName = item.getFieldName();
	    String fileName = item.getName();
	    String contentType = item.getContentType();
	    boolean isInMemory = item.isInMemory();
	    long sizeInBytes = item.getSize();
	    out.print("JSP is dealing with "+fileName+"<br>");
		
	    //File dirs = new File(TMP_DIR_PATH);
		
		//the script has to write the directory tmpDir int which we write the file, otherwise error!
		//if (!dirs.isDirectory()){dirs.mkdirs();}
		out.print("JSP is dealing with "+fileName+"<br>");
		File uploadedFile = new File(fileName);
	    item.write(uploadedFile);

	    //Reading the file and creating the database
 		XMLReader xr = XMLReaderFactory.createXMLReader();
 		XmlToDb handler = new XmlToDb();
 		xr.setContentHandler(handler);
 		xr.setErrorHandler(handler);
 		
 		FileReader f = new FileReader(fileName);
 		xr.parse(new InputSource(f));
 		uploadedFile.delete();
 		out.print("Database successfully created");
    }
}






// String nodeID = request.getParameter("id").toString();
// String relationType = request.getParameter("rel").toString();

// String cypherQuery = request.getParameter("query");
// EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

// String csvFilePath = "/home/antoine/workspace/test.csv";
// File f = new File(csvFilePath);
// Scanner csvScanner = new Scanner(f);

// Node currentNode = graphDb.getNodeById(Long.valueOf(request.getParameter("id"))); 
// HashMap<String, Node> nodesToUpdate = new HashMap<String, Node>();

// String line = csvScanner.nextLine();
// String[] elmts = line.split(",");// contains the two elements of the current csv row
// // attributeName is the attribute to consider to identify one node only and change its value
// String attributeNameToUpdate = elmts[1].trim();
// String attributeNameToIdentify = elmts[0].trim();

// if (NodeHelper.getType(currentNode).equals("Peptidome")){
// 	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING);
// 	for (Relationship rel : allRels){
// 		Node otherNode = rel.getOtherNode(currentNode);
// 		if (otherNode.hasProperty("Sequence")){
// 			if (nodesToUpdate.containsKey(otherNode.getProperty("Sequence"))){
// 				System.out.println("not unique!!");
// 			}else{
// 				nodesToUpdate.put(otherNode.getProperty("Sequence").toString(), otherNode);
// 			}
// 		}
// 	}
	
// 	try
// 	{
// 		Transaction tx = graphDb.beginTx();
// 		while (csvScanner.hasNextLine()) {
// 			line = csvScanner.nextLine();
// 			elmts = line.split(",");
// 			//System.out.println(nodesToUpdate.get(elmts[0].trim()).getProperty("type"));
			
// 			nodesToUpdate.get(elmts[0].trim()).setProperty(attributeNameToUpdate, elmts[1].trim());
			
// 		 }
// 		tx.success();
// 		tx.finish();
// 	}
// 	catch(Exception e)
// 	{
// 		e.printStackTrace();
// 	}
// 	finally
// 	{
// 		//graphDb.shutdown();
// 	}
	
	
	
	
// }else{
// 	out.print("operation not available for this node!");
// }




%>