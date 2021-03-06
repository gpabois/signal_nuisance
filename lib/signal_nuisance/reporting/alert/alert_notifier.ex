defmodule SignalNuisance.Reporting.AlertNotifier do
  import Swoosh.Email

  alias SignalNuisance.Mailer
  
  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Signal'Nuisance", "contact@signal-nuisance.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_token_based_receipt(recipient, report, token) do
    deliver(recipient, "Récipissé de signalement ##{report.id}", """ 
    Bonjour,

    Nous confirmons avoir bien reçu votre signalement n°#{report.id}.

    Vous pouvez y accéder via le lien #{token}.

    Cordialement,

    L'automate de Signal'Nuisance.
    """)
  end

  def deliver_user_based_receipt(recipient, report) do
    deliver(recipient, "Récipissé de signalement ##{report.id}", """ 
    Bonjour,

    Nous confirmons avoir bien reçu votre signalement n°#{report.id}.

    Vous pouvez y accéder via le lien #{report.id}.

    Cordialement,

    L'automate de Signal'Nuisance.
    """)
  end

end