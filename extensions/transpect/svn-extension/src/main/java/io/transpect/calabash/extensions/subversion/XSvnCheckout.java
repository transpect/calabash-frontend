package io.transpect.calabash.extensions.subversion;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import com.xmlcalabash.core.XMLCalabash;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcConstants;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

import org.tmatesoft.svn.core.SVNDepth;
import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.wc.SVNRevision;
import org.tmatesoft.svn.core.wc.SVNClientManager;
import org.tmatesoft.svn.core.wc.SVNUpdateClient;

import io.transpect.calabash.extensions.subversion.XSvnConnect;
import io.transpect.calabash.extensions.subversion.XSvnXmlReport;
/**
 * Checkout a working copy of a SVN repository
 *
 */
public class XSvnCheckout extends DefaultStep {
    private WritablePipe result = null;
    
    public XSvnCheckout(XProcRuntime runtime, XAtomicStep step) {
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
        String username = getOption(new QName("username")).getString();
        String password = getOption(new QName("password")).getString();
        String url = getOption(new QName("repo")).getString();
        String path = getOption(new QName("path")).getString();
        String revision = getOption(new QName("revision")).getString();
        XSvnXmlReport report = new XSvnXmlReport();
	try{
	    XSvnConnect connection = new XSvnConnect(path, username, password);
            SVNClientManager clientmngr = connection.getClientManager();
            SVNUpdateClient updateClient = clientmngr.getUpdateClient();
            String baseURI = connection.isRemote() ? path : connection.getPath();
            SVNURL svnurl = SVNURL.parseURIEncoded( url );
            File checkoutPath = new File(path);
            SVNRevision svnRevision, svnPegRevision;
            boolean allowUnversionedObstructions = false;
            if(revision.trim().isEmpty()){
                svnRevision = svnPegRevision = SVNRevision.HEAD;
            } else {
                svnRevision = svnPegRevision = SVNRevision.parse(revision);
            }            
            long checkoutRevision = updateClient.doCheckout(svnurl, checkoutPath, svnPegRevision, svnRevision, SVNDepth.IMMEDIATES, allowUnversionedObstructions);
            HashMap<String, String> results = new HashMap<String, String>();
            results.put("repo", svnurl.toString());
            results.put("revision", String.valueOf(checkoutRevision));
            results.put("path", checkoutPath.getCanonicalFile().toString());
            XdmNode xmlResult = report.createXmlResult(results, runtime, step);
            result.write(xmlResult);
	} catch(SVNException|IOException svne) {
	    System.out.println(svne.getMessage());
            XdmNode xmlError = report.createXmlError(svne.getMessage(), runtime, step);
	    result.write(xmlError);
	}
    }
}
