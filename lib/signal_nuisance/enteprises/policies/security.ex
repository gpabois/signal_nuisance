defmodule SignalNuisance.Enterprises.SecurityPolicy do
  @behaviour Bodyguard.Policy

  def authorize(:assign_permissions, user, {%SignalNuisance.Enterprises.Enterprise{} = enterprise, _to}) do
    SignalNuisance.Enterprises.Authorization.EnterprisePermission.has?(
      user,
      {:manage, :members},
      enterprise
    )
  end

  def authorize({:access, %SignalNuisance.Enterprises.Enterprise{} = enterprise}, user, _to) do
    SignalNuisance.Enterprises.Authorization.EnterprisePermission.has?(
      user,
      {:manage, :members},
      enterprise
    )
  end

end
