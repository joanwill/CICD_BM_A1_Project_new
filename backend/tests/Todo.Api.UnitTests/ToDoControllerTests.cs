// Adjust namespaces to match your API
using _0BMA1Api.Controllers;
using _0BMA1Api.Repository;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using _0BMA1Api;

#nullable enable

namespace Todo.Api.UnitTests
{
   

    [TestClass]
    public class ToDoControllerTests
    {
        private Mock<ITodoRepository> _todoRepository  = new Mock<ITodoRepository>();
        private ToDoController CreateController()
        {
            var logger = Mock.Of<ILogger<ToDoController>>();
          
            return new ToDoController(_todoRepository.Object, logger);
        }

        [TestMethod]
        public void Weather_Get_returns_five_entries()
        {
            var ctrl = CreateController();
            _todoRepository.Setup(x => x.GetAllAsync()).ReturnsAsync(new List<TodoItem> { new TodoItem()
            ,new TodoItem(),new TodoItem(),new TodoItem(),new TodoItem()});
            var result = ctrl.GetItem();
            result.Should().NotBeNull();
            result.Count().Should().Be(5, "the template endpoint returns 5 entries");
        }

        [TestMethod]
        public void Todos_GetItem_returns_non_empty_list_with_expected_shape()
        {
            var ctrl = CreateController();
            _todoRepository.Setup(x => x.GetAllAsync()).ReturnsAsync(new List<TodoItem> { new TodoItem
            {
                Due = DateTime.Now.AddDays(1),
                UserId = Guid.NewGuid().ToString(),
                Description = "descript"
            }
            });
            var items = ctrl.GetItem();

            items.Should().NotBeNull();
            items.Count().Should().BeGreaterThan(0);
            foreach (var t in items)
            {
                t.Due.Should().BeOnOrAfter(DateTime.Now.AddDays(1).Date.AddDays(-1));
                t.UserId.Should().NotBeNullOrEmpty();
                t.Description.Should().NotBeNullOrEmpty();
            }
        }
    }
}
