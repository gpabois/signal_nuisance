defmodule SignalNuisance.Enterprises.SecurityPolicy do
  @behaviour Bodyguard.Policy

  def authorize({:assign_permissions, %SignalNuisance.Enterprises.Enterprise{} = enterprise}, user, _to) do
    SignalNuisance.Enterprises.Authorization.EnterprisePermission.has?(
      user,
      {:manage, :members},
      enterprise
    )
  end

  def authorize({:add_member, %SignalNuisance.Enterprises.Enterprise{} = enterprise}, user, _member) do
    SignalNuisance.Enterprises.Authorization.EnterprisePermission.has?(
      user,
      {:manage, :members},
      enterprise
    )
  end

  def authorize({:remove_member, %SignalNuisance.Enterprises.Enterprise{} = enterprise}, user, _member) do
    SignalNuisance.Enterprises.Authorization.EnterprisePermission.has?(
      user,
      {:manage, :members},
      enterprise
    )
  end

  def authorize({:access, :view, :register_enterprise}, nil, _args) do
    false
  end

  def authorize({:access, :view, :member_management}, user, %SignalNuisance.Enterprises.Enterprise{} = enterprise) do
    SignalNuisance.Enterprises.Authorization.EnterprisePermission.has?(
      user,
      {:manage, :members},
      enterprise
    )
  end

  def authorize({:update, :general_settings}, user, %SignalNuisance.Enterprises.Enterprise{} = enterprise) do
    SignalNuisance.Enterprises.Authorization.EnterprisePermission.has?(
      user,
      {:manage, :enterprise},
      enterprise
    )
  end

  def authorize({:access, :view, :general_settings}, user, %SignalNuisance.Enterprises.Enterprise{} = enterprise) do
    SignalNuisance.Enterprises.Authorization.EnterprisePermission.has?(
      user,
      {:manage, :enterprise},
      enterprise
    )
  end

  def authorize({:access, :view, :dashboard}, user, %SignalNuisance.Enterprises.Enterprise{} = enterprise) do
    SignalNuisance.Enterprises.Authorization.EnterprisePermission.has?(
      user,
      {:access, :common},
      enterprise
    )
  end

  def authorize({:access, :view, :dashboard}, user, %SignalNuisance.Enterprises.Establishment{} = establishment) do
    SignalNuisance.Enterprises.Authorization.EstablishmentPermission.has?(
      user,
      {:access, :common},
      establishment
    )
  end

  def authorize({:broadcast, :message, %SignalNuisance.Enterprises.Establishment{} = establishment}, user, _message) do
    SignalNuisance.Enterprises.Authorization.EstablishmentPermission.has?(
      user,
      {:manage, :communication},
      establishment
    )
  end

  def authorize({:reply, :alert, %SignalNuisance.Enterprises.Establishment{} = establishment}, user, _message) do
    SignalNuisance.Enterprises.Authorization.EstablishmentPermission.has?(
      user,
      {:manage, :communication},
      establishment
    )
  end
end
