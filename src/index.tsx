import React from "react";
import ReactDOM from "react-dom";
import { Elm } from "./Elm/Main";

export default function App() {
  const [count, setCount] = React.useState(0);
  return (
    <div>
      <h1>Elm In React</h1>
      <ReactComponent count={count} setCount={setCount} />
      <ElmComponent count={count} setCount={setCount} />
    </div>
  );
}

interface ComponentProps {
  count: number;
  setCount: Function;
}

function ElmComponent({ count, setCount }: ComponentProps) {
  const [app, setApp] = React.useState<Elm.ElmApp | undefined>();
  const elmRef = React.useRef(null);

  const elmApp = () => Elm.Main.init({ node: elmRef.current, flags: { count: count }});

  React.useEffect(() => {
    setApp(elmApp());
  }, []);

  // Subscribe to state changes from Elm
  React.useEffect(() => {
    app &&
      app.ports.interopFromElm.subscribe((fromElm: { tag: String; data: { count: number; }; }) => {
        switch (fromElm.tag) {
          case "updateCount": {
            setCount(fromElm.data.count);
            break;
          }
        }
      });
  }, [app]);

  return <div ref={elmRef}></div>;
}

function ReactComponent({ count }: ComponentProps) {
  return (
    <div>
      <h2>This is a React Component</h2>
      <div>Count: {count}</div>
    </div>
  );
}

ReactDOM.render(<App />, document.querySelector("#root"));
