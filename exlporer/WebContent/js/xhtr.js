// create an XMLHttpRequest object 
function getXMLHttpRequest() {
	var xhr = null;
	
	if (window.XMLHttpRequest || window.ActiveXObject) {
		if (window.ActiveXObject) {
			try {
				xhr = new ActiveXObject("Msxml2.XMLHTTP");
			} catch(e) {
				xhr = new ActiveXObject("Microsoft.XMLHTTP");
			}
		} else {
			xhr = new XMLHttpRequest(); 
		}
	} else {
		alert("Votre navigateur ne supporte pas l'objet XMLHTTPRequest...");
		return null;
	}
	
	return xhr;
}

// call the jsp script to fetch information from the DB
function fetchPeptidesLength(callback) {
	var xhr = getXMLHttpRequest();
	
	xhr.onreadystatechange = function() {
		if (xhr.readyState == 4 && (xhr.status == 200 || xhr.status == 0)) {
			callback(xhr.responseText);
		}
	};
	xhr.open("GET", "charts/peptidesLength.jsp", true);
	xhr.send(null);
}


function drawPeptidesLength(sData) {
	// On peut maintenant traiter les donnees sans encombrer l'objet XHR.
	dataTab = sData.split("|")[0].split(",");
	labels = sData.split("|")[1].split(",");
	
	var data=new Array();;
	for(var i = 0; i < dataTab.length; i++){
		data[i]=parseInt(dataTab[i]); 
	}
	alert(sData);
	// extjs histogram
}

//a button calls fetchPeptidesLength(drawPeptidesLength);
