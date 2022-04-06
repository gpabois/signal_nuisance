defmodule MD.Helpers do
    import Phoenix.LiveView.Helpers
    import Phoenix.HTML.Form

    defp label_id(form, field) do
        "label-#{input_id(form, field)}"
    end

    def md_snackbar(message, opts \\ []) do
        assigns = %{
            message: message,
            action: Keyword.get(opts, :action, nil),
            class: Keyword.get(opts, :class, "")
        }

        ~H"""
        <aside class="mdc-snackbar mdc-snackbar--open" style="z-index: 99999" mdc-auto-init="MDCSnackbar">
            <div class="mdc-snackbar__surface" role="status" aria-relevant="additions">
                <div class="mdc-snackbar__label" aria-atomic="false">
                    <%= message %>
                </div>
                <%= case @action do %>
                    <% {label, click} -> %>
                    <div class="mdc-snackbar__actions" aria-atomic="true">
                        <button type="button" class="mdc-button mdc-snackbar__action" phx-click={click}>
                            <div class="mdc-button__ripple"></div>
                            <span class="mdc-button__label"><%= label %></span>
                        </button>
                    </div>
                    <% _ -> %>
                <% end %>
            </div>
        </aside>
        """
    end

    def md_slider(form, field, min, max, step, opts \\ []) do
        assigns = %{
            form: form,
            field: field,
            min: min, max: max, step: step,
            label: Keyword.get(opts, :label, field),
            class: Keyword.get(opts, :class, "")
        }

        ~H"""
        <div class={"mdc-slider #{@class}"} data-mdc-auto-init="MDCSlider">
            <input class="mdc-slider__input" type="range" min={@min} max={@max} step={@step} value={input_value(@form, @field) || @min} name={input_name(@form, @field)} aria-label={@label}>
            <div class="mdc-slider__track">
                <div class="mdc-slider__track--inactive"></div>
                <div class="mdc-slider__track--active">
                <div class="mdc-slider__track--active_fill"></div>
                </div>
            </div>
            <div class="mdc-slider__thumb">
                <div class="mdc-slider__thumb-knob"></div>
            </div>
        </div>
        """
    end

    def md_input(form, field, opts \\ []) do
        assigns = %{
            form: form,
            field: field,
            type: Keyword.get(opts, :type, "text"),
            name: Keyword.get(opts, :name, input_name(form, field)),
            id: Keyword.get(opts, :id, input_id(form, field)),
            label: Keyword.get(opts, :label, field),
            class: Keyword.get(opts, :class, "")
        }

        ~H"""
        <label class={"mdc-text-field mdc-text-field--filled #{@class}"} data-mdc-auto-init="MDCTextField">
            <span class="mdc-text-field__ripple"></span>
            <span class="mdc-floating-label" id={label_id(form, field)}><%= @label %></span>
            <input class="mdc-text-field__input" name={@name} id={@id} type={@type} aria-labelledby={label_id(form, field)}>
            <span class="mdc-line-ripple"></span>
        </label>
        """
    end

    def md_select(form, field, values, opts \\ []) do
        assigns = %{
            form: form,
            field: field,
            values: values,
            name: Keyword.get(opts, :name, input_name(form, field)),
            id: Keyword.get(opts, :id, input_id(form, field)),
            label: Keyword.get(opts, :label, field),
            class: Keyword.get(opts, :class, "")
        }
        ~H"""
        <div lass={"mdc-select #{@class}"} data-mdc-auto-init="MDCSelect">
            <i class="mdc-select__dropdown-icon"></i>
            <select class="mdc-select__native-control" id={@id} name={@name}>
                <option value="" disabled selected></option>
                <%= for value <- @values do %>
                    <%= case value do %>
                    <% {label, value} -> %>
                        <option value={value}>
                            <%= label %>
                        </option>
                    <% value -> %>
                        <option value={value}>
                            <%= value %>
                        </option>
                    <% end %>
                <% end %>
            </select>
            <label class="mdc-floating-label"><%= @label %></label>
            <div class="mdc-line-ripple"></div>
        </div>
        """
    end
end
