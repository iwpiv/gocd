/*************************GO-LICENSE-START*********************************
 * Copyright 2014 ThoughtWorks, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *************************GO-LICENSE-END***********************************/

package com.thoughtworks.go.server.messaging;

import com.thoughtworks.go.util.SystemEnvironment;
import com.thoughtworks.go.util.SystemUtil;
import static org.hamcrest.core.Is.is;
import org.junit.After;
import static org.junit.Assert.assertThat;
import org.junit.Test;

public class EmailMessageDrafterTest {
    private String artifactRoot = "artifactFolder";
    private int port = 8153;

    @After
    public void tearDown() throws Exception {
        new SystemEnvironment().clearProperty(SystemEnvironment.ARTIFACT_WARNING_SIZE_LIMIT);
        new SystemEnvironment().clearProperty(SystemEnvironment.ARTIFACT_FULL_SIZE_LIMIT);
    }

    @Test
    public void shouldDraftLowArtifactDiskSpaceEmail() throws Exception {
        String size = "1234";
        int noDiskSpaceSize = 100;
        new SystemEnvironment().setProperty(SystemEnvironment.ARTIFACT_WARNING_SIZE_LIMIT, size);
        String email = "admin@mail.com";
        SendEmailMessage message = EmailMessageDrafter.lowArtifactsDiskSpaceMessage(new SystemEnvironment(), email, artifactRoot, "http://test.host/go/help/installing_go_server.html");
        String ip = SystemUtil.getFirstLocalNonLoopbackIpAddress();
        assertThat(message, is(new SendEmailMessage(
                "Low artifacts disk space warning message from Go Server at " + ip,
                lowArtifactDiskSpaceEmail(ip, size, noDiskSpaceSize, "test.host"), email
        )));
    }

    @Test
    public void shouldDraftNoArtifactDiskSpaceEmail() throws Exception {
        String size = "2345";
        new SystemEnvironment().setProperty(SystemEnvironment.ARTIFACT_FULL_SIZE_LIMIT, size);
        String email = "admin@mail.com";
        SendEmailMessage message = EmailMessageDrafter.noArtifactsDiskSpaceMessage(new SystemEnvironment(), email, artifactRoot, "http://test.host/go/help/installing_go_server.html");
        String ip = SystemUtil.getFirstLocalNonLoopbackIpAddress();
        assertThat(message, is(new SendEmailMessage(
                "No artifacts disk space error message from Go Server at " + ip,
                noArtifactDiskSpaceEmail(ip, size, "test.host"), email
        )));
    }

    private String lowArtifactDiskSpaceEmail(String ip, String size, int noDiskSpaceSize, String hostSiteUrl) {
        return String.format("The email has been sent out automatically by the Go server at (%s) to Go administrators.\n"
            + "\n"
            + "This server has less than %sMb of disk space available at %s to store artifacts. "
            + "When the available space goes below %sMb, Go will stop scheduling. "
            + "Please ensure enough space is available. You can read more about Go's artifacts repository, "
            + "including our recommendation to create a separate partition for it at "
            + "http://%s/go/help/installing_go_server.html\n", ip, size, artifactRoot, noDiskSpaceSize, hostSiteUrl);
    }

    private String noArtifactDiskSpaceEmail(String ip, String size, String hostSiteUrl) {
        return String.format("The email has been sent out automatically by the Go server at (%s) to Go administrators.\n"
            + "\n"
            + "This server has stopped scheduling because it has less than %sMb of disk space available at %s to store artifacts. "
            + "Please ensure enough space is available. You can read more about Go's artifacts repository, "
            + "including our recommendation to create a separate partition for it at "
            + "http://%s/go/help/installing_go_server.html\n", ip, size, artifactRoot, hostSiteUrl);
    }
}