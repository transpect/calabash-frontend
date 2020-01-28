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
import org.tmatesoft.svn.core.wc.SVNRevision;
import org.tmatesoft.svn.core.wc.SVNClientManager;
import org.tmatesoft.svn.core.wc.SVNUpdateClient;

import io.transpect.calabash.extensions.subversion.XSvnConnect;
import io.transpect.calabash.extensions.subversion.XSvnXmlReport;
/**
 * Updates one or multiple paths and their children 
 * in a SVN working copy.
 *
 */
public class XSvnUpdate extends DefaultStep {
    private WritablePipe result = null;
    
    public XSvnUpdate(XProcRuntime runtime, XAtomicStep step) {
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
        String path = getOption(new QName("path")).getString();
        String revision = getOption(new QName("revision")).getString();
        XSvnXmlReport report = new XSvnXmlReport();
	try{
            String[] paths = path.split(" ");
            File[] filePaths = new File[paths.length];
	    XSvnConnect connection = new XSvnConnect(paths[0], username, password);
            SVNClientManager clientmngr = connection.getClientManager();
            SVNUpdateClient updateClient = clientmngr.getUpdateClient();
            String baseURI = connection.isRemote() ? paths[0] : connection.getPath();
            SVNRevision svnRevision;
            boolean allowUnversionedObstructions = true;
            boolean depthIsSticky = true;;
            if(revision.trim().isEmpty()){
                svnRevision = SVNRevision.HEAD;                
            } else {
                svnRevision = SVNRevision.parse(revision);
            }            
            for(int i = 0; i < paths.length; i++) {
                filePaths[i] = new File(paths[i]);
            }
            long[] updatedRevision = updateClient.doUpdate(filePaths, svnRevision, SVNDepth.INFINITY, allowUnversionedObstructions, depthIsSticky);
            HashMap<String, String> results = new HashMap<String, String>();
            for(int i = 0; i < updatedRevision.length; i++) {
                results.put(paths[i], String.valueOf(updatedRevision[i]));
            }
            XdmNode xmlResult = report.createXmlResult(results, runtime, step);
            result.write(xmlResult);
	} catch(SVNException|IOException svne) {
	    System.out.println(svne.getMessage());
            XdmNode xmlError = report.createXmlError(svne.getMessage(), runtime, step);
	    result.write(xmlError);
	}
    }
}
