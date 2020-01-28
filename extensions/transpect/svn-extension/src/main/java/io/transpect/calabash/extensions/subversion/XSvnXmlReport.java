package io.transpect.calabash.extensions.subversion;

import java.net.URI;
import java.net.URISyntaxException;

import java.util.HashMap;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcConstants;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;
/**
 * Returns XML-based reports or errors as result for
 * further processing in XProc pipelines
 *
 */
public class XSvnXmlReport {
    /**
     * Render a HashMap as XML c:param-set
     */
    public XdmNode createXmlResult(HashMap<String, String> results, XProcRuntime runtime, XAtomicStep step){
        TreeWriter tree = new TreeWriter(runtime);
        tree.startDocument(step.getNode().getBaseURI());
        tree.addStartElement(XProcConstants.c_param_set);
        for(String key:results.keySet()) {
            tree.addStartElement(XProcConstants.c_param);
            tree.addAttribute(new QName("name"), key);
            tree.addAttribute(new QName("value"), results.get(key));
            tree.addEndElement();
        }
        tree.addEndElement();
        tree.endDocument();
        return tree.getResult();
    }
    public XdmNode createXmlResult(String baseURI, String type, String[] results, XProcRuntime runtime, XAtomicStep step){
        TreeWriter tree = new TreeWriter(runtime);
        tree.startDocument(step.getNode().getBaseURI());
        tree.addStartElement(XProcConstants.c_param_set);
        tree.addAttribute(new QName("xml", "http://www.w3.org/XML/1998/namespace", "base"), baseURI);
        for(int i = 0; i < results.length; i++){
            tree.addStartElement(XProcConstants.c_param);
            tree.addAttribute(new QName("name"), type);
            tree.addAttribute(new QName("value"), results[i]);
            tree.addEndElement();
        }
        tree.addEndElement();
        tree.endDocument();
        return tree.getResult();
    }
    /**
     * Render errors as XML c:errors
     */
    public XdmNode createXmlError(String message, XProcRuntime runtime, XAtomicStep step){
        TreeWriter tree = new TreeWriter(runtime);
        tree.startDocument(step.getNode().getBaseURI());
        tree.addStartElement(XProcConstants.c_errors);
        tree.addAttribute(new QName("code"), "svn-error");
        tree.addStartElement(XProcConstants.c_error);
        tree.addAttribute(new QName("code"), "error");
        tree.addText(message);
        tree.addEndElement();
        tree.addEndElement();
        tree.endDocument();
        return tree.getResult();
    }
}
