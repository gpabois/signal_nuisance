defmodule SignalNuisance.Reporting.Authorization do
    alias SignalNuisance.Reporting.Authorization.ReportPermission
    alias SignalNuisance.Authorization.CommonPermission
    
    def can(user, reporting, opts \\ []) do
        wth = Keyword.get(opts, :with, [])
        case opts do
          [{:create, :report}    | _] -> CommonPermission.has_permission?(user, {:create, :report})
          [other | tail] -> 
            if other in ReportPermission.permissions() do
              ReportPermission.has_permission?(user, reporting, other, wth)
            else
              can(user, reporting, tail)
            end
          [] -> false
        end
    end
end