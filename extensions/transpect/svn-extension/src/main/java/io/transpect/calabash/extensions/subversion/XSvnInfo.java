package io.transpect.calabash.extensions.subversion;

import java.util.HashMap;

import java.io.File;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import com.xmlcalabash.core.XMLCalabash;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;

import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.wc.SVNWCClient;
import org.tmatesoft.svn.core.wc.SVNRevision;
import org.tmatesoft.svn.core.wc.SVNInfo;

import io.transpect.calabash.extensions.subversion.XSvnConnect;
import io.transpect.calabash.extensions.subversion.XSvnXmlReport;
/**
 * This class provides the svn info command as 
 * XML Calabash extension step for XProc. The class 
 * connects to a Subversion repository and provides 
 * the results as XML document.
 *
 * @see XSvnConnect
 */
public class XSvnInfo extends DefaultStep {
    private WritablePipe result = null;
    
    public XSvnInfo(XProcRuntime runtime, XAtomicStep step) {
        super(runtime,step);
    }
    @Override
    public void setOutput(String port, WritablePipe pipe) {
        result = pipe;
    }
    @Override
    public void reset() {
        result.resetWriter();
    }
    @Override
    public void run() throws SaxonApiException {
        super.run();

	String url = getOption(new QName("repo")).getString();
        String username = getOption(new QName("username")).getString();
        String password = getOption(new QName("password")).getString();
        XSvnXmlReport report = new XSvnXmlReport();
	try{
	    XSvnConnect connection = new XSvnConnect(url, username, password);
	    SVNWCClient client = connection.getClientManager().getWCClient();
            SVNInfo info;
            if(connection.isRemote()){
                info = client.doInfo(connection.getSVNURL(), SVNRevision.HEAD, SVNRevision.HEAD);
            } else {
                info = client.doInfo(new File(url), SVNRevision.HEAD);
            }
            HashMap<String, String> results = getSVNInfo(info);
	    XdmNode xmlResult = report.createXmlResult(results, runtime, step);
	    result.write(xmlResult);
	}catch(SVNException svne){
	    System.out.println(svne.getMessage());
            XdmNode xmlError = report.createXmlError(svne.getMessage(), runtime, step);
	    result.write(xmlError);
	}
    }
    /**
     * Create a HashMap from a SVNInfo object
     */
    private HashMap<String, String> getSVNInfo(SVNInfo info){
        HashMap<String, String> results = new HashMap<String, String>();
	results.put("url", info.getURL().toString());
	results.put("author", info.getAuthor());
	results.put("date", info.getCommittedDate().toString());
	results.put("uuid", info.getRepositoryUUID());
	results.put("rev", String.valueOf(info.getCommittedRevision().getNumber()));
	results.put("path", info.getPath());
	results.put("root-url", info.getRepositoryRootURL().toString());
	results.put("nodekind", info.getKind().toString());
	return results;
    }
}
