package com.harunichi.common.storage;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.azure.storage.blob.models.PublicAccessType;

@Configuration
public class AzureBlobConfig {

    private static final String CONN =
        "DefaultEndpointsProtocol=https;AccountName=yoonjiwonstorage;AccountKey=txVKQLmNuZzlkAUZ16D4ugHzoGLl+YCrNO/x12A0P7i5Z3AbGzw8YaglKKiyI3y0Kuim2loKBpL6+AStD2KQCg==;EndpointSuffix=core.windows.net";

    private static final String CONTAINER = "images-harunichi";

    @Bean
    public BlobServiceClient blobServiceClient() {
        return new BlobServiceClientBuilder()
                .connectionString(CONN)
                .buildClient();
    }

    @Bean
    public BlobContainerClient imagesHarunichiContainer(BlobServiceClient svc) {
        BlobContainerClient c = svc.getBlobContainerClient(CONTAINER);
        if (!c.exists()) {
            c = svc.createBlobContainer(CONTAINER);
            
            c.setAccessPolicy(PublicAccessType.BLOB, null);
        }
        return c;
    }
}
