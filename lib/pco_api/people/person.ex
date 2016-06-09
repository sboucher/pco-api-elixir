defmodule PcoApi.People.Person do
  import PcoApi.Record
  use PcoApi.Actions

  import PcoApi.RecordAssociation
  linked_association :addresses
  linked_association :apps
  linked_association :connnected_people
  linked_association :emails
  linked_association :field_data
  linked_association :household_memberships
  linked_association :households
  linked_association :inactive_reason
  linked_association :marital_status
  linked_association :message_groups
  linked_association :messages
  linked_association :name_prefix
  linked_association :name_suffix
  linked_association :phone_numbers
  linked_association :school
  linked_association :social_profiles

  def get, do: get("people/v2/people")
  def get(id) when is_integer(id), do: get("people/v2/people/#{id}")
  def get(params) when is_list(params), do: get(params, "people/v2/people")
  def get(url), do: get(url, [])

  def get(params, url) when is_list(params) and is_binary(url), do: get(url, params)
  def get(url, params) when is_binary(url) and is_list(params), do: request(:get, url, params) |> to_record

  #use PcoApi.Actions.Create
  ##### NEEDED HERE
  def create(%PcoApi.Record{attributes: _, type: _} = record), do: create(record, "people/v2/people")
  #####
  def self(%PcoApi.Record{links: %{"self" => self}}), do: get self
  def self(%PcoApi.Record{id: id}), do: get "people/v2/people/#{id}"

  def new(attrs) when is_list(attrs) do
    attrs_map = Enum.into(attrs, %{}, fn({k,v}) -> {Atom.to_string(k), v} end)
    %PcoApi.Record{attributes: attrs_map, type: "Person"}
  end
end
