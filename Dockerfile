# =====================================================================
# Dockerfile para desplegar CoreasERP.Api en Render, Koyeb, Railway o Fly.io
# =====================================================================
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copiar archivos necesarios de ambos proyectos (CoreasERP.Api enlaza modelos y servicios de CoreasERP)
COPY ["CoreasERP.Api/CoreasERP.Api.csproj", "CoreasERP.Api/"]
RUN dotnet restore "CoreasERP.Api/CoreasERP.Api.csproj"

COPY ["CoreasERP/Models/", "CoreasERP/Models/"]
COPY ["CoreasERP/Data/", "CoreasERP/Data/"]
COPY ["CoreasERP/Services/", "CoreasERP/Services/"]
COPY ["CoreasERP.Api/", "CoreasERP.Api/"]

WORKDIR "/src/CoreasERP.Api"
RUN dotnet publish "CoreasERP.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "CoreasERP.Api.dll"]
