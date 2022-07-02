defmodule SignalNuisance.Administration.SecurityPolicy do
    @behaviour Bodyguard.Policy

    alias SignalNuisance.Administration.Authorization.Permission, as: AdminPermission
    alias SignalNuisance.Administration

    def authorize({:view, :administration}, user, _) do
        Administration.is_administrator?(user)
    end

    def authorize(:assign_administration_permissions, user, to) do
        user != to and AdminPermission.has?(user, {:manage, :administration}, {})
    end

    def authorize({:manage, :alerts}, user, _) do
        AdminPermission.has?(user, {:manage, :alerts}, {})
    end

    def authorize({:view, :alert_types}, user, _) do
        authorize({:manage, :alerts}, user, {})
    end

    def authorize({:create, :alert_type}, user, _) do
        authorize({:manage, :alerts}, user, {})
    end

    def authorize({:edit, :alert_type}, user, _) do
        authorize({:manage, :alerts}, user, {})
    end

    def authorize({:delete, :alert_type}, user, _) do
        authorize({:manage, :alerts}, user, {})
    end

    def authorize({:manage, :users}, user, _) do
        AdminPermission.has?(user, {:manage, :users}, {})
    end

    def authorize({:view, :users}, user, _) do
        AdminPermission.has?(user, {:manage, :users}, {})
    end

    def authorize({:view, :user}, user, _) do
        AdminPermission.has?(user, {:manage, :users}, {})
    end

    def authorize({:delete, :user}, user, _) do
        AdminPermission.has?(user, {:manage, :users}, {})
    end

    def authorize({:acces, :view, :administration_permissions}, user, _) do
        AdminPermission.has?(user, {:manage, :administration}, {})
    end

    def authorize({:manage, :facilities}, user, _) do
        AdminPermission.has?(user, {:manage, :facilities}, {})

    end
    def authorize({:update, :facility}, user, _facility) do
        authorize {:manage, :facilities}, user, {}
    end

    def authorize({:delete, :facility}, user, _facility) do
        authorize {:manage, :facilities}, user, {}
    end

    def authorize({:view, :facilities}, user, _facility) do
        authorize {:manage, :facilities}, user, {}
    end

    def authorize({:view, :facility}, user, _facility) do
        authorize {:manage, :facilities}, user, {}
    end
end
