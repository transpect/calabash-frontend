import java.io.File;
import java.io.PrintWriter;
import java.net.URI;
import java.io.StringWriter;
import java.io.StringReader;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.core.XMLCalabash;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.DocumentBuilder;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.QName;

import com.adobe.epubcheck.api.EpubCheck;
import com.adobe.epubcheck.api.Report;
import com.adobe.epubcheck.util.XmlReportImpl;

public class EpubCheckExtension extends DefaultStep
{
  private WritablePipe result = null;

  public EpubCheckExtension(XProcRuntime runtime, XAtomicStep step)
  {
    super(runtime,step);
  }
  @Override
  public void setOutput(String port, WritablePipe pipe)
  {
    result = pipe;
  }
  @Override
  public void reset()
  {
    result.resetWriter();
  }
  @Override
  public void run() throws SaxonApiException
  {
    super.run();
    RuntimeValue href = getOption(new QName("href"));
    String path = href.getString();
    URI uri = href.getBaseURI().resolve(path);
    File file = new File(path);
    StringWriter stringWriter = new StringWriter();
    try(PrintWriter pw = new PrintWriter(stringWriter, true))
    {
      Report epubcheckReport = new XmlReportImpl(pw, uri.toString(), EpubCheck.version());
      EpubCheck epubcheck = new EpubCheck(file, epubcheckReport);
      epubcheck.validate();
      epubcheckReport.generate();
      String XMLResult = stringWriter.toString();
      DocumentBuilder builder = runtime.getProcessor().newDocumentBuilder();
      Source src = new StreamSource(new StringReader(XMLResult));
      XdmNode doc = builder.build(src);
      result.write(doc);
    }
  }
}
