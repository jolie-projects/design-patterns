jolie Service_Registry.ol &
echo ServiceRegistry
cd db
jolie initDB.ol
echo InitDB
jolie StatsDatabase.ol &
echo StatsDB
cd ..
jolie website.ol &
