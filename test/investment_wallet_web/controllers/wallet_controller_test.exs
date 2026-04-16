defmodule InvestmentWalletWeb.WalletControllerTest do
  use InvestmentWalletWeb.ConnCase, async: true

  def mock_assigned_stocks do
    [
      %{"name" => "Apple Inc.", "code" => "AAPL"},
      %{"name" => "Apple Inc.", "code" => "AAPL"},
      %{"name" => "Apple Inc.", "code" => "AAPL"},
      %{"name" => "Apple Inc.", "code" => "AAPL"},
      %{"name" => "Apple Inc.", "code" => "AAPL"},
      %{"name" => "Apple Inc.", "code" => "AAPL"},
      %{"name" => "Apple Inc.", "code" => "AAPL"}
    ]
  end

  describe "POST /api/rebalance" do
    test "return wallet with rebalance", %{conn: conn} do
      payload = %{
        "wallet" => %{
          "name" => "My Wallet",
          "assigned_stocks" => mock_assigned_stocks(),
          "wish_stocks" => [
            %{"code" => "AAPL", "percentaje" => "50"},
            %{"code" => "META", "percentaje" => "50"}
          ]
        }
      }
      response =
        conn
        |> post(~p"/api/rebalance", payload)
        |> json_response(200)

      assert Map.has_key?(response, "wallet")
      wallet = response["wallet"]
      assert wallet["to_buy_stocks"] === [%{"code" => "META", "units" => 1}]
      assert wallet["to_sell_stocks"] === [%{"code" => "AAPL", "units" => 4}]
    end
    test "returns error when wish_stocks percentages do not sum to 100", %{conn: conn} do
      invalid_payload = %{
        "wallet" => %{
          "name" => "My Wallet",
          "assigned_stocks" => mock_assigned_stocks(),
          "wish_stocks" => [
            %{"code" => "AAPL", "percentaje" => "50"},
            %{"code" => "META", "percentaje" => "49"}
          ]
        }
      }

      response =
        conn
        |> post(~p"/api/rebalance", invalid_payload)
        |> json_response(400)

      assert response["status"] == "error"
      assert response["message"] == "allocation_not_one"
    end

    test "returns error when wish_stocks is empty", %{conn: conn} do
      invalid_payload = %{
        "wallet" => %{
          "name" => "My Wallet",
          "assigned_stocks" => mock_assigned_stocks(),
          "wish_stocks" => []
        }
      }

      response =
        conn
        |> post(~p"/api/rebalance", invalid_payload)
        |> json_response(400)

      assert response["status"] == "error"
      assert response["message"] == "wish_stocks_empty"

    end
  end
end
