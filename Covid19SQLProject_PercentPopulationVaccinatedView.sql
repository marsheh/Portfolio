Create view PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(convert(int,V.new_vaccinations)) OVER (Partition by D.location Order By D.location, 
D.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ D
Inner Join PortfolioProjects..CovidVaccinations$ V
On D.location = V.location and D.date = V.date
Where D.continent is not null
--Order By D.location, D.date

Select * 
From PercentPopulationVaccinated