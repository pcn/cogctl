defmodule Cogctl.Actions.Groups.Create do
  use Cogctl.Action, "groups create"
  alias Cogctl.Table

  def option_spec do
    [{:name, :undefined, 'name', {:string, :undefined}, 'Group name (required)'}]
  end

  def run(options, _args, _config, client) do
    with_authentication(client,
                        &do_create(&1, :proplists.get_value(:name, options)))
  end

  defp do_create(_client, :undefined) do
    display_arguments_error
  end

  defp do_create(client, name) do
    case CogApi.group_create(client, %{group: %{name: name}}) do
      {:ok, resp} ->
        group = resp["group"]
        name = group["name"]

        group_attrs = for {title, attr} <- [{"ID", "id"}, {"Name", "name"}] do
          [title, group[attr]]
        end

        display_output("""
        Created #{name}

        #{Table.format(group_attrs, false)}
        """ |> String.rstrip)
      {:error, error} ->
        display_error(error["error"])
    end
  end
end
