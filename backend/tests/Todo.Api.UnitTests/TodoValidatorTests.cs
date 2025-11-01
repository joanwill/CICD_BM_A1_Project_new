using FluentAssertions;
using Xunit;

public class TodoValidatorTests
{
    [Fact]
    public void Title_required()
    {
        var v = new TodoValidator();
        var result = v.Validate(new TodoItem { Title = "" });
        result.IsValid.Should().BeFalse();
    }

    [Fact]
    public void Priority_range()
    {
        var v = new TodoValidator();
        var result = v.Validate(new TodoItem { Title = "X", Priority = 5 });
        result.IsValid.Should().BeFalse();
    }
}
