defmodule PcoApi.People.WorkflowTest do
  use ExUnit.Case, async: false
  doctest PcoApi.People.Workflow
  alias PcoApi.People.Workflow
  alias TestHelper.Fixture

  setup do
    bypass = Bypass.open
    Application.put_env(:pco_api, :endpoint_base, "http://localhost:#{bypass.port}/")
    {:ok, bypass: bypass}
  end

  # .get
  test ".get requests the v2 endpoint", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/people/v2/workflows/" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, Fixture.read("workflow.json"))
    end
    Workflow.get
  end

  test ".get returns a list of Record structs", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      Plug.Conn.resp(conn, 200, Fixture.read("workflows.json"))
    end
    assert [%PcoApi.Record{} | _rest] = Workflow.get
  end

  test ".get(id) returns a single record", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/people/v2/workflows/1" == conn.request_path
      Plug.Conn.resp conn, 200, Fixture.read("me.json")
    end
    workflow = Workflow.get(1)
    assert %PcoApi.Record{id: "1"} = workflow
  end

  test ".get queries from a params list", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/people/v2/workflows/" == conn.request_path
      assert "where%5Bname%5D=Visitors" == conn.query_string
      Plug.Conn.resp(conn, 200, Fixture.read("workflows.json"))
    end
    PcoApi.Query.where(name: "Visitors")
    |> Workflow.get
  end

  test ".get queries a params list and a specific path", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/people/v2/workflows/foo" == conn.request_path
      assert "where%5Bname%5D=Visitors" == conn.query_string
      Plug.Conn.resp(conn, 200, Fixture.read("workflows.json"))
    end
    PcoApi.Query.where(name: "Visitors")
    |> Workflow.get("foo")
  end

  test ".self retrieves the details of a Workflow when passed a single record", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/people/v2/workflows/1" == conn.request_path
      Plug.Conn.resp(conn, 200, Fixture.read("workflow.json"))
    end
    workflow = %PcoApi.Record{links: %{"self" => "https://api.planningcenteronline.com/people/v2/workflows/1"}}
    workflow |> Workflow.self
  end

  test ".self gets Workflow details even if no self link", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/people/v2/workflows/1000" == conn.request_path
      Plug.Conn.resp(conn, 200, Fixture.read("workflow.json"))
    end
    %PcoApi.Record{id: "1000", links: %{}} |> Workflow.self
  end

  test ".cards gets a list of cards with a cards link", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/people/v2/workflows/1/cards" == conn.request_path
      Plug.Conn.resp(conn, 200, Fixture.read("workflow_cards.json"))
    end
    record_with_link |> Workflow.cards
  end

  test ".steps gets a list of steps with a steps link", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/people/v2/workflows/1/steps" == conn.request_path
      Plug.Conn.resp(conn, 200, Fixture.read("workflow_steps.json"))
    end
    record_with_link |> Workflow.steps
  end

  def record_with_link do
    cards_url = "https://api.planningcenteronline.com/people/v2/workflows/1/cards"
    steps_url = "https://api.planningcenteronline.com/people/v2/workflows/1/steps"
    %PcoApi.Record{
      links: %{"cards" => cards_url, "steps" => steps_url},
      type: "Workflow"
    }
  end
end
