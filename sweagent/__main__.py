from sweagent.run.run import main
from sweagent.tracer import Tracer
import sweagent.debugger
from sweagent.debugger.debugger_client import AgentDebugger
from datetime import datetime

if __name__ == "__main__":
    tracer = Tracer(run_id=datetime.now().strftime("run_%b_%d_%H-%M-%S"))
    tracer.instrument_class(AgentDebugger, name_prefix="AgentDebugger", library="sweagent.debugger")
    
    try:
        with tracer.program("entire_run", scenario="baseline"):
            main()
    except KeyboardInterrupt:
        raise
    finally:
        print('Saving trace...')
        tracer.restore()
        tracer.save()
