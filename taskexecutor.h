#ifndef TASKEXECUTOR_H
#define TASKEXECUTOR_H

#include <QObject>

#include <deque>
#include <functional>
#include <mutex>
#include <atomic>


//this class executes all tasks in m_work_thread
class TaskExecutor
{
    using tasks_t = std::deque<std::function<void()>>;
    std::mutex m_tasks_mtx;
    tasks_t m_tasks;
    std::atomic<bool> m_is_stopped;
public:
    TaskExecutor();
    ~TaskExecutor();
    //add task to queue
    void AddTask(std::function<void()> task);
private:
    void WorkRoutine();
};

#endif // TASKEXECUTOR_H
