import { State, Action, StateContext, Selector } from '@ngxs/store';
import { tap } from 'rxjs/operators';
import { Injectable } from '@angular/core';
import { TodoActions } from 'todo [example]/actions/todo.action';
import { TodoService } from 'todo [example]/service/todo.service';
import { Todo } from 'todo [example]/models/Todo';

export type TodoStateModel = {
  todos: Todo[];
  selectedTodo: Todo | null;
};

@State<TodoStateModel>({
  name: 'todos',
  defaults: {
    todos: [],
    selectedTodo: null,
  },
})
@Injectable()
export class TodoState {
  constructor(private todoService: TodoService) {}

  @Selector()
  static getTodoList(state: TodoStateModel) {
    return state.todos;
  }

  @Selector()
  static getSelectedTodo(state: TodoStateModel) {
    return state.selectedTodo;
  }

  @Action(TodoActions.GetTodos)
  getTodos({ getState, setState }: StateContext<TodoStateModel>) {
    return this.todoService.fetchTodos().pipe(
      tap(result => {
        const state = getState();
        setState({
          ...state,
          todos: result,
        });
      })
    );
  }

  @Action(TodoActions.AddTodo)
  addTodo(
    { getState, patchState }: StateContext<TodoStateModel>,
    { payload }: TodoActions.AddTodo
  ) {
    return this.todoService.addTodo(payload).pipe(
      tap(result => {
        const state = getState();
        patchState({
          todos: [...state.todos, result],
        });
      })
    );
  }

  @Action(TodoActions.UpdateTodo)
  updateTodo(
    { getState, setState }: StateContext<TodoStateModel>,
    { payload, id }: TodoActions.UpdateTodo
  ) {
    return this.todoService.updateTodo(payload, id).pipe(
      tap(result => {
        const state = getState();
        const todoList = [...state.todos];
        const todoIndex = todoList.findIndex(item => item.id === id);
        todoList[todoIndex] = result;
        setState({
          ...state,
          todos: todoList,
        });
      })
    );
  }

  @Action(TodoActions.DeleteTodo)
  deleteTodo({ getState, setState }: StateContext<TodoStateModel>, { id }: TodoActions.DeleteTodo) {
    return this.todoService.deleteTodo(id).pipe(
      tap(() => {
        const state = getState();
        const filteredArray = state.todos.filter(item => item.id !== id);
        setState({
          ...state,
          todos: filteredArray,
        });
      })
    );
  }

  @Action(TodoActions.SetSelectedTodo)
  setSelectedTodoId(
    { getState, setState }: StateContext<TodoStateModel>,
    { payload }: TodoActions.SetSelectedTodo
  ) {
    const state = getState();
    setState({
      ...state,
      selectedTodo: payload,
    });
  }
}
