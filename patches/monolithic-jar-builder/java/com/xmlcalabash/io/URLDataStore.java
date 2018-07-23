/*
 * URLDataStore.java
 *
 * Copyright 2013 3 Round Stones Inc.
 * Some rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.xmlcalabash.io;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import static java.net.URLConnection.guessContentTypeFromName;
import java.net.FileNameMap;
import java.nio.file.FileSystem;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;

/**
 * Uses {@link URLConnection} to implement the interface.
 * 
 * @author James Leigh &lt;james@3roundstones.com&gt;
 * 
 */
public class URLDataStore implements DataStore {
	private final DataStore fallback;

	public URLDataStore(DataStore fallback) {
		super();
		this.fallback = fallback;
	}

	public URI writeEntry(String href, String base, String media,
			DataWriter handler) throws MalformedURLException,
			FileNotFoundException, IOException {
		URI baseURI = URI.create(base);
		URI uri = baseURI.resolve(href);
		URLConnection conn = uri.toURL().openConnection();
		conn.setRequestProperty("Content-Type", media);
		conn.setDoOutput(true);
		conn.setDoInput(false);
		OutputStream stream = conn.getOutputStream();
		try {
			handler.store(stream);
		} finally {
			stream.close();
		}
		String location = conn.getHeaderField("Content-Location");
		URI url = URI.create(conn.getURL().toExternalForm());
		if (location == null) {
			return url;
		} else {
			return url.resolve(location);
		}
	}

    public void readEntry(String href, String base, String accept,
                              String overrideContentType, DataReader handler) throws MalformedURLException,
                                                                                     FileNotFoundException, IOException {
        URI baseURI = URI.create(base);
        URL url = baseURI.resolve(href).toURL();
        URLConnection connection = url.openConnection();
        connection.setRequestProperty("Accept", accept);
        final InputStream stream = connection.getInputStream();
        FileNameMap fileNameMap = URLConnection.getFileNameMap();
        try {
            String type = connection.getContentType();
            if (((type == null) || "content/unknown".equals(type)) && href.startsWith("jar:") && href.contains("!")) {
                // Unfortunately, neither
                // java.nio.file.Files.probeContentType() nor
                // FileNameMap.getContentTypeFor() nor
                // guessContentTypeFromName() were able to report the
                // content type of a .js resource. probeContentType()
                // was at least able to report text/css
                switch (href.replaceAll("^.+\\.(.+)(\\?.*)?(#.*)?$", "$1")) {
                case "css" :
                    type = "text/css"; break;
                case "js" :
                    type = "application/javascript"; break;
                case "png" :
                case "PNG" :
                    type = "image/png"; break;
                case "jpg" :
                case "jpeg" :
                case "JPG" :
                case "JPEG" :
                    type = "image/jpeg"; break;
                case "svg" :
                case "SVG" :
                    type = "application/octet-stream"; break;
                default:
                    type = "application/octet-stream";
                }
                // String[] parts = href.split("!");
                // Map<String, String> env = new HashMap<>();
                // URI jar_uri = URI.create(parts[0]);
                // try (FileSystem zipfs = FileSystems.newFileSystem(jar_uri, env)) {
                //     System.out.println("PARTS: " + parts[0] + " :: " + parts[1] + " :: "  + Files.probeContentType(zipfs.getPath(parts[1])));
                //     zipfs.close();
                // } catch (Exception e) {
                //     System.out.println("PURTS: " + parts[0] + parts[1]);
                // }
            }
            //type = ((type == null) || "content/unknown".equals(type)) ? guessContentTypeFromName(href) : type;
            if (overrideContentType != null) {
                type = overrideContentType;
            }
            URI id = URI.create(connection.getURL().toExternalForm());
            long len = 0;
            
            // Call getContentLengthLong if it's available
            try {
                Method lenMethod = connection.getClass().getDeclaredMethod("getContentLengthLong");
                lenMethod.invoke(connection);
            } catch (Exception e) {
                // Whatever...
                len = connection.getContentLength();
            }
            
            handler.load(id, type, stream, len);
        } finally {
            stream.close();
        }
    }

	public void infoEntry(String href, String base, String accept,
			DataInfo handler) throws MalformedURLException,
			FileNotFoundException, IOException {
		URI baseURI = URI.create(base);
		URL url = baseURI.resolve(href).toURL();
		URLConnection connection = url.openConnection();
		connection.setRequestProperty("Accept", accept);
		final InputStream stream = connection.getInputStream();
		try {
			String type = connection.getContentType();
			URI id = URI.create(connection.getURL().toExternalForm());
			handler.list(id, type, connection.getLastModified());
		} finally {
			stream.close();
		}
	}

	public void listEachEntry(String href, String base, String accept,
			DataInfo handler) throws MalformedURLException,
			FileNotFoundException, IOException {
		fallback.listEachEntry(href, base, accept, handler);
	}

	public URI createList(String href, String base)
			throws MalformedURLException, FileNotFoundException, IOException {
		return fallback.createList(href, base);
	}

	public void deleteEntry(String href, String base)
			throws MalformedURLException, FileNotFoundException, IOException {
		fallback.deleteEntry(href, base);
	}

}
