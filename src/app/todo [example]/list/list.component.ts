import { Component, OnInit } from '@angular/core';
import { TodoState } from '../states/todo.state';
import { Select, Store } from '@ngxs/store';
import { Todo } from '../models/Todo';
import { Observable } from 'rxjs';
import { TodoActions } from 'todo [example]/actions/todo.action';

@Component({
  selector: 'app-list',
  templateUrl: './list.component.html',
  styleUrls: ['./list.component.scss'],
})
export class ListComponent implements OnInit {
  @Select(TodoState.getTodoList) todos!: Observable<Todo[]>;

  constructor(private store: Store) {}

  ngOnInit() {
    this.store.dispatch(new TodoActions.GetTodos());
  }

  deleteTodo(id: number) {
    this.store.dispatch(new TodoActions.DeleteTodo(id));
  }

  editTodo(todo: Todo) {
    this.store.dispatch(new TodoActions.SetSelectedTodo(todo));
  }
}
