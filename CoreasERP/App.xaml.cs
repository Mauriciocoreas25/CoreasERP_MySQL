namespace CoreasERP;

public partial class App : Application
{
	public App()
	{
		InitializeComponent();

		AppDomain.CurrentDomain.UnhandledException += (s, e) =>
		{
			try
			{
				string logFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "CoreasERP_Crash.log");
				File.AppendAllText(logFile, $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] UNHANDLED DOMAIN: {e.ExceptionObject}\n\n");
			}
			catch { }
		};

		TaskScheduler.UnobservedTaskException += (s, e) =>
		{
			try
			{
				string logFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "CoreasERP_Crash.log");
				File.AppendAllText(logFile, $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] UNOBSERVED TASK: {e.Exception}\n\n");
			}
			catch { }
		};
	}

	protected override Window CreateWindow(IActivationState? activationState)
	{
		return new Window(new MainPage()) { Title = "CoreasERP" };
	}
}
