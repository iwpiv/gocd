##########################GO-LICENSE-START################################
# Copyright 2014 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################GO-LICENSE-END##################################

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Api::AgentsController do
  before do
    controller.stub!(:agent_service).and_return(@agent_service = mock('agent-service'))
    controller.stub!(:current_user).and_return(@user = Object.new)
  end

  describe :index do
    it "should resolve to list agents" do
      route_for(:controller => "api/agents", :action => "index", :format => 'json', :no_layout => true ).should == "/api/agents"
      agents_information_path.should == "/api/agents"
    end

    it "should get agents json" do
      two_agents = AgentsViewModelMother.getTwoAgents()

      agents_api_arr = Array.new
      two_agents.each do |agent|
        agents_api_arr << AgentAPIModel.new(agent)
      end

      @agent_service.should_receive(:agents) do
        two_agents
      end

      get :index, :no_layout => true, :format => 'json'
      response.body.should == agents_api_arr.to_json
    end

    it "should get empty json when there are no agents" do
      zero_agents = AgentsViewModelMother.getZeroAgents()

      @agent_service.should_receive(:agents) do
        zero_agents
      end

      get :index, :no_layout => true, :format => 'json'
      response.body.should == "[]"
    end
  end

  describe :delete do
    it "should render result" do
      @agent_service.should_receive(:deleteAgents).with(@user, anything(), ["abc"]) do |user, result, uuid|
        result.notAcceptable("Not Acceptable", HealthStateType.general(HealthStateScope::GLOBAL))
      end
      post :delete, :uuid => "abc", :no_layout => true
      response.status.should == "406 Not Acceptable"
    end

    it "should resolve as /api/agents/UUID/delete" do
      params_from(:post, "/api/agents/123abc/delete").should == {:uuid => "123abc", :action => "delete", :controller => 'api/agents', :no_layout => true}
      raise_error do
        params_from(:get, "/api/agents/123abc/delete")
      end
    end
  end

  describe :disable do
    it "should render result" do
      @agent_service.should_receive(:disableAgents).with(@user, anything(), ["abc"]) do |user, result, uuid|
        result.notAcceptable("Not Acceptable", HealthStateType.general(HealthStateScope::GLOBAL))
      end
      post :disable, :uuid => "abc", :no_layout => true
      response.status.should == "406 Not Acceptable"
    end

    it "should resolve as /api/agents/UUID/disable" do
      params_from(:post, "/api/agents/123abc/disable").should == {:uuid => "123abc", :action => "disable", :controller => 'api/agents', :no_layout => true}
      raise_error do
        params_from(:get, "/api/agents/123abc/disable")
      end
    end
  end

  describe :enable do
    it "should render result" do
      @agent_service.should_receive(:enableAgents).with(@user, anything(), ["UUID1"]) do |user, result, uuids|
        result.notAcceptable("Not Acceptable", HealthStateType.general(HealthStateScope::GLOBAL))
      end
      post :enable, :uuid => "UUID1", :no_layout => true
      response.status.should == "406 Not Acceptable"
    end

    it "should resolve as /api/agents/UUID/enable" do
      params_from(:post, "/api/agents/123abc/enable").should == {:uuid => "123abc", :action => "enable", :controller => 'api/agents', :no_layout => true}
      raise_error do
        params_from(:get, "/api/agents/123abc/enable")
      end
    end
  end

  describe :edit_agents do
    it "should show message if there is a problem" do
      @agent_service.should_receive(:enableAgents).with(@user, anything(), ["UUID1", "UUID2"]) do |user, result, uuids|
        result.notAcceptable("Error message", HealthStateType.general(HealthStateScope::GLOBAL))
      end
      post :edit_agents, :operation => 'Enable', :selected => ["UUID1", "UUID2"], :no_layout => true
      response.body.should ==  "Error message"
    end

    it "should show message for a successful bulk_edit" do
      @agent_service.should_receive(:enableAgents).with(@user, anything(), ["UUID1", "UUID2"]) do |user, result, uuids|
        result.ok("Enabled 3 agent(s)")
      end
      post :edit_agents, :operation => 'Enable', :selected => ["UUID1", "UUID2"], :no_layout => true
      response.body.should == "Enabled 3 agent(s)"

    end

    it "should show message for an unrecognised operation" do
      post :edit_agents, :operation => 'BAD_OPERATION', :selected => ["UUID1", "UUID2"], :no_layout => true
      response.body.should == "The operation BAD_OPERATION is not recognized."
    end

    it "should show error if selected parameter is omitted" do
      post :edit_agents, :operation => 'Enable', :no_layout => true
      response.body.should == "No agents were selected. Please select at least one agent and try again."

    end

    it "should show error if no agents are selected" do
      post :edit_agents, :operation => 'Enable', :selected => [], :no_layout => true
      response.body.should == "No agents were selected. Please select at least one agent and try again."
    end
  end
end
