defmodule SignalNuisance.Administration.SecurityPolicy do
    @behaviour Bodyguard.Policy

    alias SignalNuisance.Administration.Authorization.Permission, as: AdminPermission

    def authorize({:access, :view, :administration_dashboard}, user, _) do
        AdminPermission.has?(user, {:access, :administration}, {})
    end

    def authorize(:assign_administration_permissions, user, to) do
        user != to and AdminPermission.has?(user, {:manage, :administration}, {})
    end

    def authorize({:acces, :view, :administration_permissions}, user, _) do
        AdminPermission.has?(user, {:manage, :administration}, {})
    end
end
  