package com.harunichi.common.storage;

import java.io.InputStream;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.models.BlobHttpHeaders;

@Service
public class AzureBlobStorageService {

	private final BlobContainerClient container;
	
	@Autowired
	public AzureBlobStorageService(BlobContainerClient imagesHarunichiContainer) {
		this.container = imagesHarunichiContainer;
	}

	// dir: "profile" 또는 "board"
	public UploadResult upload(String dir, MultipartFile file) throws Exception {
		if (file == null || file.isEmpty())
			return null;

		String original = file.getOriginalFilename();
		String ext = (original != null && original.lastIndexOf(".") > -1)
				? original.substring(original.lastIndexOf("."))
				: "";
		String name = UUID.randomUUID().toString() + ext;
		String objectPath = dir + "/" + name;

		BlobClient blob = container.getBlobClient(objectPath);
		try (InputStream in = file.getInputStream()) {
			blob.upload(in, file.getSize(), true);
		}
		String contentType = file.getContentType() != null ? file.getContentType() : "application/octet-stream";
		blob.setHttpHeaders(new BlobHttpHeaders().setContentType(contentType));

		String url = blob.getBlobUrl(); // 절대 URL
		return new UploadResult(objectPath, url);
	}

	public boolean deleteByObjectPath(String objectPath) {
		if (objectPath == null || objectPath.isEmpty())
			return false;
		BlobClient blob = container.getBlobClient(objectPath);
		if (blob.exists()) {
			blob.delete();
			return true;
		}
		return false;
	}

	/** DB에 절대 URL을 저장했을 때, objectPath로 되돌리는 보조 메서드 */
	public String toObjectPath(String absoluteUrl) {
		String marker = "/" + container.getBlobContainerName() + "/";
		int i = absoluteUrl.indexOf(marker);
		return (i > -1) ? absoluteUrl.substring(i + marker.length()) : absoluteUrl;
	}

	public static class UploadResult {
		public final String objectPath; // e.g. profile/xxxx.jpg
		public final String url; // absolute URL

		public UploadResult(String objectPath, String url) {
			this.objectPath = objectPath;
			this.url = url;
		}
	}

}
