defmodule SignalNuisance.Reporting.AlertUserBinding do
    use Ecto.Schema

    import Ecto.Changeset
    # import Ecto.Query
    # import Geo.PostGIS
  
    alias SignalNuisance.Repo
    alias SignalNuisance.Reporting.Alert
    alias SignalNuisance.Accounts.User
  
    schema "alert_user_bindings" do
      belongs_to :user,  User
      belongs_to :alert, Alert    
    end   
    
    def bind(alert, entity) do
      
    end    

    def unbind(alert, entity) do
      
    end
end