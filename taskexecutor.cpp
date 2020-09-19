#include "taskexecutor.h"
#include <QCoreApplication>
#include <QDebug>
#include <QtConcurrent>

TaskExecutor::TaskExecutor()
    : m_is_stopped(false)
{
    QtConcurrent::run(this, &TaskExecutor::WorkRoutine);
}

TaskExecutor::~TaskExecutor()
{
    m_is_stopped.store(true);
}

void TaskExecutor::AddTask(std::function<void()> task)
{
    std::lock_guard<std::mutex> _ (m_tasks_mtx);
    m_tasks.push_back(std::move(task));
}

void TaskExecutor::WorkRoutine()
{
    while (true)
    {
        if (m_is_stopped.load(std::memory_order_relaxed))
            return;
        tasks_t tasks;
        {
            std::lock_guard<std::mutex> _ (m_tasks_mtx);
            tasks = std::move(m_tasks);
        }
        if (tasks.empty())
        {
            QCoreApplication::processEvents();
        }
        else
        {
            for (const auto& task : tasks)
                task();
        }
    }
}
