I have created a docker file to use rethinkdb without having to install it.

Unlike mongodb, it looks like rethinkdb does not have a REPL to interact with it,
there is an adminstrative interface but attempts to expose the port from the container
to the host did not take off.

I ended up using the NODE repl inside the database. Rethinkdb requires that we use a driver to
connect to it.

To build and run the docker container:

```
docker build . - t rethinkdb-node
docker run --ti --rm rethinkdb-node bash
```

To start rethinkdb:

```bash
rethinkdb
rethinkdb --bind=all
```

To run rethinkdb as a deamon, use:

```bash
sudo cp /etc/rethinkdb/default.conf.sample /etc/rethinkdb/instances.d/instance1.conf
echo "bind=all" >> /etc/rethinkdb/instances.d/instance1.conf
sudo /etc/init.d/rethinkdb restart
```

> The official docker image is based on `debian, does not need `sudo`.

The following features of the Node.js driver were used:

1. To connect to a rethinkdb database

```js
let conn = null
r.connect({ host, port}, (err, c) => {
  if (err) { // do something about it }
  conn = c
})
```

2. By default, rethinkddb already has a `test` database, to create a new `table` in this database:

```js
r.db('test').tableCreate('tableName').run(conn, (err, res) => {})
```

Every query executed on a rethinkdb database must use `.run` and pass it a connection to indicate the end of
all chained methods.The result in many cases such as this is metadata about the operation performed.

3. To insert data,  use the following:

```js
r..table('authors').insert([{data}, {data}]).run(conn, (err, res) => {})
```

To update and delete data use:

```js
r.table('authors').update({type: 'fictional'}).run(conn, (err, res) => {})
r.table('authors').delete(filterCriteria).run(conn, (err, res) => {})
```

4. The data in a table can be queried using `.filter` method:

```js
r.table('authors').filter(r.row('name').eq('SOmething')).run(conn, (err, cursor) => {
  if (err) // handle error
  cursor.toArray((err, arr) => {
    // get data as `arr`
  })
})
```

Data is retrieved when a query is run using a `cursor`, however a cursor can be stepped through and converted to an array using `cursor.toArray` in case the size of the data set is insignificant.

---

The main showcase of rethinkdb is `changefeeds`, to retrieve a field when it has been updated:

```js
r.table('authors').changes().run(conn, (err, cursor) => {
  if (err) throw err
  // cannot use cursor.toArray here
  cursor.each((err, row) => {
    if (err) throw err
    // get the row, it contains the `old_value` and the `new_value` of the given row
  })
})
```

The information here is based on the following links:

[Deamon](https://www.rethinkdb.com/docs/start-on-startup/)

[JS Driver](https://www.rethinkdb.com/docs/guide/javascript/)

[Docker](https://hub.docker.com/_/rethinkdb/)

[Custom Dockerfile from](https://hub.docker.com/r/blakek13/node-rethinkdb/)

> The custom dockerfile is published onto dockerhub, but it only uses Node v6, I wanted to use Node v8.
