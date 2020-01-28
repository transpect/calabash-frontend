package io.transpect.calabash.extensions.subversion;

import java.io.File;
import java.io.IOException;

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
import org.tmatesoft.svn.core.SVNProperties;
import org.tmatesoft.svn.core.wc.SVNClientManager;
import org.tmatesoft.svn.core.wc.SVNCommitClient;

import io.transpect.calabash.extensions.subversion.XSvnConnect;
import io.transpect.calabash.extensions.subversion.XSvnXmlReport;
/**
 * Commits one or more paths and their children 
 * in a SVN working directory to the assigned repository.
 *
 */
public class XSvnCommit extends DefaultStep {
    private WritablePipe result = null;
    
    public XSvnCommit(XProcRuntime runtime, XAtomicStep step) {
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
        String commitMessage = getOption(new QName("message")).getString();
        XSvnXmlReport report = new XSvnXmlReport();
	try{
            String[] paths = path.split(" ");
            File[] filePaths = new File[paths.length];
            for(int i = 0; i < paths.length; i++) {
                filePaths[i] = new File(paths[i]);
            }
	    XSvnConnect connection = new XSvnConnect(paths[0], username, password);
            SVNClientManager clientmngr = connection.getClientManager();
            String baseURI = connection.isRemote() ? paths[0] : connection.getPath();
            SVNCommitClient commitClient = clientmngr.getCommitClient();
            Boolean keepLocks = false;
            SVNProperties svnProps = new SVNProperties();
            String[] changelists = null;
            Boolean keepChangelist = false;
            Boolean force = false;
            commitClient.doCommit(filePaths, keepLocks, commitMessage, svnProps, changelists, keepChangelist, force, SVNDepth.IMMEDIATES);
            XdmNode xmlResult = report.createXmlResult(baseURI, "commit", paths, runtime, step);
            result.write(xmlResult);
	} catch(SVNException|IOException svne) {
	    System.out.println(svne.getMessage());
            XdmNode xmlError = report.createXmlError(svne.getMessage(), runtime, step);
	    result.write(xmlError);
	}
    }
}
