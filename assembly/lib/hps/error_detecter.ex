defmodule Hps.ErrorDetecter do

    @styles %{:reset => "\u001B[0m", :bold => "\u001B[1m"}
    @colors %{:red => "\u001B[31m"}

    def lexer_error(token, file_path) do
        IO.puts(@colors[:red] <> "** (Lexer Error) invalid token \'" <> @styles[:bold] <>  @colors[:red] <> "#{token.expression}" <> @styles[:reset] <> @colors[:red] <> "\' in file #{file_path}" <> @styles[:reset])
        # System.halt(0)
    end

    def parser_error(result_token, tl, error_cause, file_path) do
        if result_token === :token_missing_error do
            IO.puts parser_localized("structure", error_cause.tag, "is missing something", file_path)
        else
            IO.puts parser_localized("token", Enum.at(tl,0).expression, "was not accepted", file_path)
        end
    end
    defp parser_localized(element, fault_token, msg, file_path) do 
        @colors[:red] <> "** (Parser Error) #{element}" <> @styles[:bold] <>  @colors[:red] <> "<#{fault_token}> " <> @styles[:reset] <> @colors[:red] <> "#{msg} in file #{file_path}"
    end
end