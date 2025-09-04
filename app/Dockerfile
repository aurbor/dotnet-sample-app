FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY WeatherApi.csproj .
RUN dotnet restore WeatherApi.csproj

# Copy source code
COPY src/ ./src/

# Build and publish
RUN dotnet publish WeatherApi.csproj -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "WeatherApi.dll"]
