defmodule SignalNuisance.Facilities.SecurityPolicy do
    @behaviour Bodyguard.Policy
  
    use SignalNuisance.Authorization
    
    alias SignalNuisance.Facilities.{Facility, FacilityMember}
    alias SignalNuisance.Facilities.Authorization.Permission

    def authorize(:manage_members, user, facility) do
      Permission.has?
        user,
        {:manage, :members},
        facility
    end

    def authorize({:add_member, %Facility{} = facility}, user, _member) do
      authorize :manage_members, user, facility
    end

    def authorize({:remove_member, %Facility{} = facility}, user, _member) do
      authorize :manage_members, user, facility
    end

    def authorize({:assign_permissions, %Facility{} = facility}, user, _to) do
      authorize :manage_members, user, facility
    end

    def authorize({:access, :view, :dashboard}, user, facility) do
      FacilityMember.is_member? facility, user
    end
  
    def authorize({:access, :view, :member_management}, user, %Facility{} = facility) do
      authorize :manage_members, user, facility
    end

    def authorize(:manage_facility, user, facility) do
      Permission.has? user, {:manage, :facility}, facility
    end

    def authorize({:update, :general_settings}, user, %Facility{} = facility) do
      authorize :manage_facility, user, facility
    end

    def authorize({:access, :view, :general_settings}, user, %Facility{} = facility) do
      authorize :manage_facility, user, facility
    end
   
    def authorize(:manage_communication, user, %Facility{} = facility) do
      Permission.has?
        user,
        {:manage, :communication},
        facility
    end

    def authorize({:broadcast, :message, %Facility{} = facility}, user, _message) do
      authorize :manage_communication, user, facility
    end
  
    def authorize({:reply, :alert, %Facility{} = facility}, user, _message) do
      authorize :manage_communication, user, facility
    end
  end
  