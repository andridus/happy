defmodule Happy.Mixfile do
  use Mix.Project

  def project do
    [app: :happy,
     version: "1.2.2",
     elixir: "~> 1.0",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def description do
    """
    Happy path programming in elixir.

    Alternative to ok_jose, elixir's 1.2 `with` keyword and that kind of stuff.
    """
  end

  def package do
    [files: ~w(lib mix.exs README* LICENSE),
     maintainers: ["Victor Hugo Borja <vborja@apache.org>"],
     licenses: ["Apache 2.0"],
     links: %{
       "GitHub" => "https://github.com/vic/happy"
     }]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:mix_test_watch, "~> 0.2", only: :dev},
     {:credo, "~> 0.2.5", only: :dev}]
  end
end
