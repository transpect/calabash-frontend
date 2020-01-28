package io.transpect.calabash.extensions.subversion;

import java.io.File;
import java.io.IOException;

import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.auth.ISVNAuthenticationManager;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.io.SVNRepositoryFactory;
import org.tmatesoft.svn.core.wc.SVNClientManager;
import org.tmatesoft.svn.core.wc.ISVNOptions;
import org.tmatesoft.svn.core.wc.SVNWCUtil;
import org.tmatesoft.svn.core.internal.io.fs.FSRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.dav.DAVRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.svn.SVNRepositoryFactoryImpl;
import org.tmatesoft.svn.core.internal.wc.DefaultSVNOptions;

import org.tmatesoft.svn.core.wc.SVNWCClient;
import org.tmatesoft.svn.core.wc.SVNRevision;
import org.tmatesoft.svn.core.wc.SVNInfo;


/**
 * This class implements SVNKit and provides methods to connect to a 
 * Subversion repository. You need to instantiate the class with the 
 * corresponding Subversion URL, username and password.
 */
public class XSvnConnect {

    private String url;
    private String username;
    private String password;
    private SVNClientManager clientManager;
    private SVNRepository repository;
    /**
     * Creates an exception given an error message. 
     * 
     * @param url an URL which identifies a Subversion repository
     * @param username username for the given repository
     * @param password password for the given repository
     *
     */
    public XSvnConnect(String url, String username, String password) throws SVNException{
	this.url = url;
	this.username = username;
	this.password = password;
	clientManager = init(username, password);
    }
    /**
     * Returns a JavaKit SVNClientManager object.
     * 
     * @return a SVNClientManager object 
     *
     * @see org.tmatesoft.svn.core.wc.SVNClientManager
     */
    public SVNClientManager getClientManager() throws SVNException{
	return clientManager;
    }
    /**
     * Returns a JavaKit SVNRepository object. 
     *
     * @return a SVNRepository object
     *
     * @see org.tmatesoft.svn.core.io.SVNRepository
     */
    public SVNRepository getRepository() throws SVNException{
	repository = clientManager.createRepository(getSVNURL(), false);
	return repository;
    }
    /**
     * Returns true if the submitted href is a URL. 
     *
     * @return boolean
     *
     */
    public boolean isRemote(){
        return isURLBool(url);
    }
    /**
     * Returns a JavaKit SVNURL object. 
     * 
     * @return a SVNURL object
     * 
     * @see org.tmatesoft.svn.core.SVNURL
     */
    public SVNURL getSVNURL() throws SVNException {
        SVNURL svnurl = null;
	if(isURLBool(url)){
	    svnurl = SVNURL.parseURIEncoded(url);
	}
	return svnurl;
    }
    public String getPath() throws IOException {
        File path = new File(url);
        return path.getCanonicalPath();
    }
    private SVNClientManager init(String username, String password) throws SVNException{
	//Set up connection protocols support:
        DAVRepositoryFactory.setup();             // http
        SVNRepositoryFactoryImpl.setup();         // svn, svn+xxx (svn+ssh in particular)
        FSRepositoryFactory.setup();              // file
	DefaultSVNOptions options = SVNWCUtil.createDefaultOptions(true);
	if(url.startsWith("http://")||url.startsWith("https://")){
	    SVNClientManager clientManager = SVNClientManager.newInstance(options, username, password);
	    return clientManager;
	}else{
	    SVNClientManager clientManager = SVNClientManager.newInstance(options, username, password);
	    SVNWCClient client = clientManager.getWCClient();
 	    return clientManager;
	}
    }
    private boolean isURLBool(String href){
        return href.startsWith("http://") || href.startsWith("https://");
    }
}
