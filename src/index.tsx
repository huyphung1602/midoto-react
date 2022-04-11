import React from "react";
import ReactDOM from "react-dom";
import { Elm } from "./Elm/Main";

export default function App() {
  const [todos, setTodos] = React.useState([]);
  return (
    <div>
      <ReactComponent todos={todos} setTodos={setTodos} />
      <ElmComponent todos={todos} setTodos={setTodos} />
    </div>
  );
}

interface ComponentProps {
  todos: ({
    id: number;
    } & {
        name: string;
    } & {
        workedTime: number;
    } & {
        previousWorkedTime: number;
    } & {
        status: "active" | "incomplete" | "completed";
    }) [];
  setTodos: Function;
}

function ElmComponent({ todos, setTodos }: ComponentProps) {
  const [app, setApp] = React.useState<Elm.ElmApp | undefined>();
  const elmRef = React.useRef(null);

  const storedState = localStorage.getItem('todo-app-save');
  const startingState = storedState ? storedState : "";
  // console.log("Retrieved state: ", storedState);
  const elmApp = () => Elm.Main.init({ node: elmRef.current, flags: { todos: startingState }});

  React.useEffect(() => {
    setApp(elmApp());
  }, []);

  // Subscribe to state changes from Elm
  React.useEffect(() => {
    app &&
      app.ports.interopFromElm.subscribe((fromElm: { tag: String; data: { todos: any; }; }) => {
        switch (fromElm.tag) {
          case "updateTodos": {
            const todosJson = JSON.stringify(fromElm.data.todos);
            localStorage.setItem('todo-app-save', todosJson);
            setTodos(fromElm.data.todos);
            break;
          }
        }
      });
  }, [app]);

  return <div ref={elmRef}></div>;
}

function ReactComponent({ todos }: ComponentProps) {
  return (
    <div>
    </div>
  );
}

ReactDOM.render(<App />, document.querySelector("#root"));
