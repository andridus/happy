defmodule HappyPathTest do
  use ExUnit.Case

  import Happy.Assertions
  import Happy

  test "match expr expands to case" do
    a = quote do
      happy_path do
        {a} = b
        c
      end
    end
    b = quote do
      b
      |> case do
           {a} -> {:happy, c}
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "empty block expands to itself" do
    a = quote do
      happy_path do
      end
    end
    b = quote do
    end
    assert_expands_to a, b, __ENV__
  end

  test "single expr expands to itself" do
     a = quote do
       happy_path do
         foo
       end
     end
     b = quote do
       foo
     end
     assert_expands_to a, b, __ENV__
  end

  test "block without matches expands to itself" do
     a = quote do
       happy_path do
         foo
         bar
       end
     end
     b = quote do
       foo
       bar
     end
     assert_expands_to a, b, __ENV__
   end

  test "block with single match expands to itself" do
     a = quote do
       happy_path do
         foo = bar
       end
     end
     b = quote do
       foo = bar
     end
     assert_expands_to a, b, __ENV__
   end

  test "block with expr and match expands to itself" do
    a = quote do
      happy_path do
        baz
        {foo} = baz
      end
    end
    b = quote do
      baz
      {foo} = baz
    end
    assert_expands_to a, b, __ENV__
  end


  test "block with elixir case expands to itself" do
    a = quote do
      happy_path do
        case bar do
          true -> nil
        end
        foo
      end
    end
    b = quote do
      case bar do
        true -> nil
      end
      foo
    end
    assert_expands_to a, b, __ENV__
  end

  test "match in middle expands to case" do
    a = quote do
      happy_path do
        a
        {c} = b
        d
      end
    end
    b = quote do
      (a
       b
       |> case do
            {c} -> {:happy, d}
            x -> x
          end
      )|> case do
            {:happy, x} -> x
            x -> x
          end
    end
    assert_expands_to a, b, __ENV__
  end

  test "block with match and expr expands to case" do
    a = quote do
      happy_path do
        {foo} = bar
        foo + 1
      end
    end
    b = quote do
      bar
      |> case do
           {foo} -> {:happy, foo + 1}
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "block with match and two exprs expands to case" do
    a = quote do
      happy_path do
        {foo} = bar
        baz
        bat
      end
    end
    b = quote do
      bar
      |> case do
           {foo} ->
             baz
             {:happy, bat}
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "block with match and three exprs expands to case" do
    a = quote do
      happy_path do
        {foo} = bar
        baz
        bat
        moo
      end
    end
    b = quote do
      bar
      |> case do
           {foo} ->
             baz
             bat
             {:happy, moo}
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "sequential matches expand to nested cases" do
    a = quote do
      happy_path do
        {b} = a
        c
        {e} = d
        f
      end
    end
    b = quote do
      a
      |> case do
           {b} ->
             c
             d |> case do
                    {e} -> {:happy, f}
                    x -> x
                  end
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "single expr with else expands to itself" do
    a = quote do
      happy_path do
        foo
      else
        :true -> :unhappy
      end
    end
    b = quote do
      foo
    end
    assert_expands_to a, b, __ENV__
  end

  test "else clause expand to unhappy case" do
    a = quote do
      happy_path do
        {foo} = bar
        foo + 1
      else
        _ -> bar
      end
    end
    b = quote do
      bar
      |> case do
           {foo} -> {:happy, foo + 1}
           x -> x
         end
      |> case do
           {:happy, x} -> x
           _ -> bar
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "multiple pattern matching" do
    a = quote do
      happy_path do
        c = b = a
        e
      end
    end
    b = quote do
      a |> case do
        c = b -> {:happy, e}
        x -> x
      end |> case do
        {:happy, x} -> x
        x -> x
      end
    end
    assert_expands_to a, b, __ENV__
  end

  test "two consecutive match expressions expand to nested case" do
    a = quote do
      happy_path do
        {b} = a
        {c} = b
        d
      end
    end
    b = quote do
      a
      |> case do
           {b} ->
             b
             |> case do
                  {c} -> {:happy, d}
                  x -> x
                end
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "happy with guard" do
    a = quote do
      happy_path do
        b when is_nil(b) = a
        c
      end
    end
    b = quote do
      a
      |> case do
           b when is_nil(b) -> {:happy, c}
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "tagged match" do
    a = quote do
      happy_path do
        @t b = a
        c
      end
    end
    b = quote do
      {:t, a}
      |> case do
           {:t, b} -> {:happy, c}
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end


  test "happy expr at match" do
    a = quote do
      happy_path do
        y
        @t b = a
        c
      end
    end
    b = quote do
      ( y
        {:t, a}
        |> case do
             {:t, b} -> {:happy, c}
             x -> x
           end
      )|> case do
            {:happy, x} -> x
            x -> x
          end
    end
    assert_expands_to a, b, __ENV__
  end

  test "nested case with tag" do
    a = quote do
      happy_path do
        {y} = x
        @t b = a
        c
      end
    end
    b = quote do
      x
      |> case do
           {y} ->
             {:t, a}
             |> case do
                  {:t, b} -> {:happy, c}
                  x -> x
                end
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "happy at when match" do
    a = quote do
      happy_path do
        @t b when w = a
        c
      end
    end
    b = quote do
      {:t, a}
      |> case do
           {:t, b} when w -> {:happy, c}
           x -> x
         end
      |> case do
           {:happy, x} -> x
           x -> x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "should not rewrite non-pattern matching expression" do
    a = quote do
      happy_path do
        x = 1
        y
      end
    end
    b = quote do
      x = 1
      y
    end
    assert_expands_to a, b, __ENV__
  end

  test "should rewrite match with existing var" do
    a = quote do
      happy_path do
        ^x = 1
        y
      end
    end
    b = quote do
      1
      |> case do
           ^x ->
             {:happy, y}
           x ->
             x
         end
      |> case do
           {:happy, x} ->
             x
           x ->
             x
         end
    end
    assert_expands_to a, b, __ENV__
  end

  test "happy_path can take fallback error handler as first argument" do
    a = quote do
      happy_path(else: handle) do
        {:ok, x} = a
        x
      else
        {:error, y} -> y
      end
    end
    b = quote do
      a
      |> case do
           {:ok, x} -> {:happy, x}
           x -> x
         end
      |> case do
           {:happy, x} -> x
           {:error, y} -> y
           x -> x |> handle
        end
    end
    assert_expands_to a, b, __ENV__
  end

  test "happy_path can take default error handler as first argument" do
    a = quote do
      happy_path!(else: handle) do
        {:ok, x} = a
        x
      end
    end
    b = quote do
      a
      |> case do
           {:ok, x} -> {:happy, x}
           x -> x
         end
      |> case do
          {:happy, x} -> x
          x -> x |> handle
        end
    end
    assert_expands_to a, b, __ENV__
  end

  test "happy_path with a match then direct set should not create compile-time warnings" do
    happy_path do
      ok = %{}
      Map.put(ok, :done, true)
    end
  end

  test "using @happy tag doesnt expand tagged match" do
    a = quote do
      happy_path do
        @happy {x, y} = {"hell", "o"}
        {:ok, x} = x
        y
      end
    end
    b = quote do
      ( {x, y} = {"hell", "o"}
        x
        |> case do
          {:ok, x} -> {:happy, y}
          x -> x
        end
      ) |> case do
          {:happy, x} -> x
          x -> x
        end
    end
    assert_expands_to a, b, __ENV__
  end

  test "using @happy tag doesnt expand into single case" do
    a = quote do
      happy_path do
        @happy {x, y} = {"hell", "o"}
        y
      end
    end
    b = quote do
      {x, y} = {"hell", "o"}
      y
    end
    assert_expands_to a, b, __ENV__
  end

end
