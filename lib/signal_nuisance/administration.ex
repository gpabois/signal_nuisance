defmodule SignalNuisance.Administration do

  alias SignalNuisance.Administration.Administrator
  alias SignalNuisance.Administration.Authorization.Permission


  def add_administrator(user) do
    Administrator.add(user)
  end

  def grant_permissions(user, permissions) do
    Permission.grant(user, permissions, {})
  end

  def remove_administrator(user) do
    Administrator.remove(user)
    Permission.revoke_all(user, {})
  end

  def is_administrator?(user) do
    Administrator.is?(user)
  end


end
